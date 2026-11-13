class DropDeletedCandidate < ActiveRecord::Migration[8.1]
  def up
    remove_index :deleted_candidates, :candidate_id
    drop_table :deleted_candidates
  end

  def down
    create_table :deleted_candidates do |t|
      t.bigint :candidate_id, null: false
      t.jsonb :deleted_records, null: false

      t.timestamps
    end
  end
end
