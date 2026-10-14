class AddAPIVersionToVendorAPIToken < ActiveRecord::Migration[8.1]
  def change
    add_column :vendor_api_tokens, :api_version, :string
  end
end
