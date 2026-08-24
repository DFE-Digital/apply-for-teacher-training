class CreateDeletedCandidates < ActiveRecord::Migration[8.1]
  def change
    create_table :deleted_candidates do |t|
      t.bigint :candidate_id, null: false
      t.jsonb :deleted_tables, null: false

      t.timestamps
    end
  end
end
