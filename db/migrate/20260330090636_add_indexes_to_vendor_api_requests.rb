class AddIndexesToVendorAPIRequests < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :vendor_api_requests, :provider_id, algorithm: :concurrently
    add_index :vendor_api_requests, :status_code, algorithm: :concurrently
    add_index :vendor_api_requests, :request_path, algorithm: :concurrently
  end
end
