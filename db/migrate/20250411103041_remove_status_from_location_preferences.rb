class RemoveStatusFromLocationPreferences < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :candidate_location_preferences, :status, :string, null: false, default: 'draft'
    end
  end
end
