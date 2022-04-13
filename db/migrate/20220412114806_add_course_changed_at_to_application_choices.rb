class AddCourseChangedAtToApplicationChoices < ActiveRecord::Migration[7.0]
  def change
    add_column :application_choices, :course_changed_at, :datetime
  end
end
