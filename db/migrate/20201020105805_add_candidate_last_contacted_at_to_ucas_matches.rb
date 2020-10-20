class AddCandidateLastContactedAtToUCASMatches < ActiveRecord::Migration[6.0]
  def change
    add_column :ucas_matches, :candidate_last_contacted_at, :datetime
  end
end
