class ChangeOfferedCourseOptionColumnType < ActiveRecord::Migration[6.0]
  def up
    change_column :application_choices, :offered_course_option_id, :bigint
  end

  def down
    change_column :application_choices, :offered_course_option_id, :integer
  end
end
