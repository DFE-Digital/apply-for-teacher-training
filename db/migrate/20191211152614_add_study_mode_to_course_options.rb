class AddStudyModeToCourseOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :course_options, :study_mode, :integer, null: false, default: 0
  end
end
