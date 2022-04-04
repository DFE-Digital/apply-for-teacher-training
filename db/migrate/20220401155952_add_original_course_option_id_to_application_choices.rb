class AddOriginalCourseOptionIdToApplicationChoices < ActiveRecord::Migration[7.0]
  def change
    add_column :application_choices, :original_course_option_id, :bigint
  end
end
