class AddCourseCodeToChaser < ActiveRecord::Migration[8.0]
  def change
    add_column :chasers_sent, :course_code, :string, null: true
  end
end
