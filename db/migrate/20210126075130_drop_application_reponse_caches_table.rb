class DropApplicationReponseCachesTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :application_response_caches
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
