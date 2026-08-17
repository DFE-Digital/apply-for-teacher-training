class AddCourseStateToCourse < ActiveRecord::Migration[8.1]
  def change
    add_column(:courses, :course_status, :string, default: 'closed', null: false)
  end
end
