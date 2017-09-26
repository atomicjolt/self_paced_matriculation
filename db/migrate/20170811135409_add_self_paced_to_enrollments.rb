class AddSelfPacedToEnrollments < ActiveRecord::Migration[5.0]
  tag :predeploy

  def change
    change_table :enrollments do |t|
      t.boolean :self_paced, default: false
    end
  end
end
