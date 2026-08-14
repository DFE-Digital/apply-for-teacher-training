class AddUnloggedToVendorAPIRequestsV2 < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    safety_assured { execute 'ALTER TABLE vendor_api_request_v2s SET UNLOGGED' }
  end

  def down
    safety_assured { execute 'ALTER TABLE vendor_api_request_v2s SET LOGGED' }
  end
end
