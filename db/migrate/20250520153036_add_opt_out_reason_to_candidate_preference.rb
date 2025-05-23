class AddOptOutReasonToCandidatePreference < ActiveRecord::Migration[8.0]
  def change
    add_column :candidate_preferences, :opt_out_reason, :text
  end
end
