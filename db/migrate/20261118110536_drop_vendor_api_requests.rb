class DropVendorAPIRequests < ActiveRecord::Migration[8.1]
  def up
    drop_table :vendor_api_requests
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
