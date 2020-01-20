class AddCourseFromFindIdToCandidateModel < ActiveRecord::Migration[6.0]
  def up
    add_column :candidates, :course_from_find_id, :integer, default: nil
  end

  def down
    remove_column :candidates, :course_from_find_id, :integer
  end
end
