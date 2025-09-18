class ChangePrecisionOnLatitudeAndLongitudeFloats < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      change_column :candidate_location_preferences, :latitude, :decimal, precision: 12, scale: 8
      change_column :candidate_location_preferences, :longitude, :decimal, precision: 12, scale: 8
    end
  end

  def down
    safety_assured do
      change_column :candidate_location_preferences, :latitude, :float
      change_column :candidate_location_preferences, :longitude, :float
    end
  end
end
