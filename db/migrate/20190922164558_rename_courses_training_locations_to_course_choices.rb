class RenameCoursesTrainingLocationsToCourseChoices < ActiveRecord::Migration[5.2]
  def change
    rename_table :courses_training_locations, :course_choices
  end
end
