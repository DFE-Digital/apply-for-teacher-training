class AddCurrentCourseOptionIdToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :current_course_option_id, :bigint
  end
end
