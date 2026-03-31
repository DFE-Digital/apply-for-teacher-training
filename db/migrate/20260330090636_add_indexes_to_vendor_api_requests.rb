class AddIndexesToVendorAPIRequests < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :vendor_api_requests, :provider_id, algorithm: :concurrently unless index_exists?(:vendor_api_requests, :provider_id)
    add_index :vendor_api_requests, :status_code, algorithm: :concurrently unless index_exists?(:vendor_api_requests, :status_code)
    add_index :vendor_api_requests, :request_path, algorithm: :concurrently unless index_exists?(:vendor_api_requests, :request_path)
  end
end
