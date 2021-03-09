class CreateApplicationChoicesWithCourses < ActiveRecord::Migration[6.0]
  def change
    create_view :application_choices_with_courses
  end
end
