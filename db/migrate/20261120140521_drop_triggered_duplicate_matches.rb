class DropTriggeredDuplicateMatches < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    drop_table :triggered_duplicate_matches
    safety_assured { remove_reference :candidates, :triggered_duplicate_match, index: { algorithm: :concurrently } }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
