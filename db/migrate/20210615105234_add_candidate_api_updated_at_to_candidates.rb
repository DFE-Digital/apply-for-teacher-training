class AddCandidateAPIUpdatedAtToCandidates < ActiveRecord::Migration[6.1]
  def change
    add_column :candidates, :candidate_api_updated_at, :datetime
  end
end
