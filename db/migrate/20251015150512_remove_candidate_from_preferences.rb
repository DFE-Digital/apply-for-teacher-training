class RemoveCandidateFromPreferences < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_reference :candidate_preferences, :candidate, foreign_key: { on_delete: :cascade }
    end
  end
end
