class ChangeVendorAPIRequestsHashedTokenToProviderId < ActiveRecord::Migration[6.0]
  def up
    remove_column :vendor_api_requests, :hashed_token
    remove_column :vendor_api_requests, :response_time
    add_column :vendor_api_requests, :provider_id, :bigint
  end

  def down
    remove_column :vendor_api_requests, :provider_id
    add_column :vendor_api_requests, :response_time, :bigint
    add_column :vendor_api_requests, :hashed_token, :string
  end
end
