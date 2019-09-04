class CreateCoursesTrainingLocations < ActiveRecord::Migration[5.2]
  def change
    create_join_table :courses, :training_locations
  end
end
