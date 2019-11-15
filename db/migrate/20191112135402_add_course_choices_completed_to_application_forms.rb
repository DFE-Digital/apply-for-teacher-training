class AddCourseChoicesCompletedToApplicationForms < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :course_choices_completed, :boolean, default: false, null: false
  end
end
