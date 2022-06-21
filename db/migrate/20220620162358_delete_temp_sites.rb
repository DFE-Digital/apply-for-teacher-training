class DeleteTempSites < ActiveRecord::Migration[7.0]
  def up
    drop_table :temp_sites
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
