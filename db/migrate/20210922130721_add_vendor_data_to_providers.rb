class AddVendorDataToProviders < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :providers, :vendor, null: true, index: { algorithm: :concurrently }
  end
end
