class AddStructuredDegreeColumnsToTheCoursesTable < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :degree_grade, :string
    add_column :courses, :degree_subject_requirements, :string
  end
end
