class ChangeColumnTypeOnLocationPreferences < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      change_column :candidate_location_preferences, :within, :float
    end
  end

  def down
    safety_assured do
      change_column :candidate_location_preferences, :within, :integer
    end
  end
end
