class SetCandidateNotNullCandidatePreferences < ActiveRecord::Migration[8.0]
  def change
    add_check_constraint(
      :candidate_preferences,
      'candidate_id IS NOT NULL',
      name: 'candidate_preferences_candidate_id_null',
      validate: false,
    )
  end
end
