class AddCanSponsorStudentVisaToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :can_sponsor_student_visa, :boolean
  end
end
