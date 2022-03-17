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

module SelfPacedMatriculation
  NAME = "Self Paced Matriculation".freeze
  DISPLAY_NAME = "Self Paced Course Enrollment".freeze
  DESCRIPTION =
    "This adds a self_paced field to the Enrollments API.".freeze

  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path(File.join(__FILE__, "../.."))
    config.eager_load_paths << File.expand_path(File.join(__FILE__, "../.."))

    initializer "self_paced_matriculation.canvas_plugin" do
      # In development we have to force loading Api::V1:User module first, so
      # the constant we want to override gets created before we append to it
      Api::V1::User
      module Api::V1::User
        API_ENROLLMENT_JSON_OPTS = (Api::V1::User.const_get("API_ENROLLMENT_JSON_OPTS") + %i[self_paced]).freeze
      end
      # Load the Canvas application controller first, then the one in the plugins
      require "app/controllers/enrollments_api_controller"
      require_relative "../../app/controllers/enrollments_api_controller"
    end
    config.to_prepare do
      Canvas::Plugin.register(
        :self_paced_enrollment_api,
        :sis,
        name: -> { I18n.t(:self_paced_name, NAME) },
        display_name: -> { I18n.t :self_paced_display, DISPLAY_NAME },
        author: "Atomic Jolt",
        author_website: "http://www.atomicjolt.com/",
        description: -> { t(:description, DESCRIPTION) },
        version: SelfPacedMatriculation::Version,
        settings: {
          valid_contexts: %w{Account Course},
        },
      )
    end
  end
end
