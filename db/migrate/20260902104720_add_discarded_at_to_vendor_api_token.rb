class AddDiscardedAtToVendorAPIToken < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :vendor_api_tokens, :discarded_at, :datetime
    add_index :vendor_api_tokens, :discarded_at, algorithm: :concurrently
  end
end
