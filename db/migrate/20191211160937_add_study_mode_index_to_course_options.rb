class AddStudyModeIndexToCourseOptions < ActiveRecord::Migration[6.0]
  def change
    remove_index :course_options, %i[site_id course_id]
    add_index :course_options, %i[site_id course_id study_mode], unique: true
  end
end
