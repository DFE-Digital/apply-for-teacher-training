class RemoveFraudMatches < ActiveRecord::Migration[6.1]
  def up
    drop_table :fraud_matches
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
