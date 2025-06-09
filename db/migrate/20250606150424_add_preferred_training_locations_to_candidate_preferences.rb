class AddPreferredTrainingLocationsToCandidatePreferences < ActiveRecord::Migration[8.0]
  def change
    add_column :candidate_preferences, :training_locations, :string
  end
end
