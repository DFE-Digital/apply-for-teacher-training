class AddCandiateIndexToDeletedCandidates < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :deleted_candidates, :candidate_id, algorithm: :concurrently
  end
end
