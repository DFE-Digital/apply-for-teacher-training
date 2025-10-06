class ValidateCandidateColumnNotNullCandidatePreferences < ActiveRecord::Migration[8.0]
  def up
    validate_check_constraint(
      :candidate_preferences,
      name: 'candidate_preferences_candidate_id_null',
    )
    change_column_null :candidate_preferences, :candidate_id, true
    remove_check_constraint(
      :candidate_preferences,
      name: 'candidate_preferences_candidate_id_null',
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
