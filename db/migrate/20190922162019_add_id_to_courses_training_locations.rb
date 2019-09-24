class AddIdToCoursesTrainingLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :courses_training_locations, :id, :primary_key
  end
end
