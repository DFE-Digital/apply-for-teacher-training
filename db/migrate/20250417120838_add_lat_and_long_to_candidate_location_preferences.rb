class AddLatAndLongToCandidateLocationPreferences < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :candidate_location_preferences, :latitude, algorithm: :concurrently
    add_index :candidate_location_preferences, :longitude, algorithm: :concurrently
  end
end
