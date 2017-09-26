# Copyright (C) 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Parts of this file have been copied from Instructure's file located at
# https://github.com/instructure/canvas-lms/app/controllers/enrollments_api_controller.rb


require_dependency "app/controllers/enrollments_api_controller"
require_dependency "lib/api"
require_dependency "lib/api/v1/user"


SELF_PACED_ENGINE_ROOT = SelfPacedMatriculation::Engine.root

class EnrollmentsApiController
  include Api::V1::User

  alias unmodified_create_enrollment create
  @@errors[:missing_dates] ||= 'start_at and end_at dates required for self_paced enrollment'

  Api::V1::User.const_get("API_ENROLLMENT_JSON_OPTS").push(:self_paced)

  def create
    errors = []

    #Check if self_paced enrollment
    if params[:enrollment][:self_paced].present? && value_to_boolean(params[:enrollment][:self_paced])
      # Canvas code for enrollment parameter checking
      if params[:enrollment].blank?
        errors << @@errors[:missing_parameters] if params[:enrollment].blank?
      else
        return create_self_enrollment if params[:enrollment][:self_enrollment_code]

        type = params[:enrollment].delete(:type)

        if role_id = params[:enrollment].delete(:role_id)
          role = @context.account.get_role_by_id(role_id)
        elsif role_name = params[:enrollment].delete(:role)
          role = @context.account.get_course_role_by_name(role_name)
        else
          type = "StudentEnrollment" if type.blank?
          role = Role.get_built_in_role(type)
          if role.nil? || !role.course_role?
            errors << @@errors[:bad_type]
          end
        end

        if role && role.course_role? && !role.deleted?
          type = role.base_role_type if type.blank?
          if role.inactive?
            errors << @@errors[:inactive_role]
          elsif type != role.base_role_type
            errors << @@errors[:base_type_mismatch]
          else
            params[:enrollment][:role] = role
          end
        elsif errors.empty?
          errors << @@errors[:bad_role]
        end

        errors << @@errors[:missing_user_id] unless params[:enrollment][:user_id].present?
      end
      # Additional parameter checking for self_paced enrollments
      if !params[:enrollment][:start_at].present? && !params[:enrollment][:end_at].present?
        errors << @@errors[:missing_dates]
      end
      # return errors if there are any
      return render_create_errors(errors) if errors.present?

      # Canvas Code to create enrollment
      params[:enrollment][:no_notify] = true unless value_to_boolean(params[:enrollment][:notify])
      unless @current_user.can_create_enrollment_for?(@context, session, type)
        render_unauthorized_action && return
      end
      params[:enrollment][:course_section_id] = @section.id if @section.present?
      if params[:enrollment][:course_section_id].present?
        @section = @context.course_sections.active.find params[:enrollment].delete(:course_section_id)
        params[:enrollment][:section] = @section
      end
      api_user_id = params[:enrollment].delete(:user_id)
      user = api_find(User, api_user_id)
      raise(ActiveRecord::RecordNotFound, "Couldn't find User with API id '#{api_user_id}'") unless user.can_be_enrolled_in_course?(@context)

      if @context.concluded?
        # allow moving users already in the course to open sections
        unless @section && user.enrollments.where(course_id: @context).exists? && !@section.concluded?
          return render_create_errors([@@errors[:concluded_course]])
        end
      end

      params[:enrollment][:limit_privileges_to_course_section] = value_to_boolean(params[:enrollment][:limit_privileges_to_course_section]) if params[:enrollment].has_key?(:limit_privileges_to_course_section)
      params[:enrollment].slice!(:enrollment_state, :section, :limit_privileges_to_course_section, :associated_user_id, :role, :start_at, :end_at, :self_enrolled, :no_notify)


      @enrollment = @context.enroll_user(user, type, params[:enrollment].merge(:allow_multiple_enrollments => true))
      # update the enrollment to set self_paced, start_at, and end_at
      # render appropriately
      if @enrollment.valid?
        @enrollment.update(
          self_paced: true,
          start_at: params[:enrollment][:start_at],
          end_at: params[:enrollment][:end_at],
        )
        render(:json => enrollment_json(@enrollment, @current_user, session))
      else
        render(:json => @enrollment.errors, :status => :bad_request)
      end
    else
      # no self_paced parameter or was false
      # check for previously enrolled in course and change self_paced to false
      user = api_find(User, params[:enrollment][:user_id])
      previous_enrollment = user.enrollments.where(course_id: @context)
      if previous_enrollment.present?
        previous_enrollment.update(self_paced: false)
      end
      unmodified_create_enrollment
    end
  end

end
