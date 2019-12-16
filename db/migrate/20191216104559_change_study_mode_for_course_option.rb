class ChangeStudyModeForCourseOption < ActiveRecord::Migration[6.0]
  def up
    change_column :course_options, :study_mode, :string, null: false, default: 'full_time'
  end

  def down
    change_column :course_options, :study_mode, :integer, null: false, default: 0
  end
end
