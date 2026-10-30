class AddPaginationToVendorAPIToken < ActiveRecord::Migration[8.1]
  def change
    add_column :vendor_api_tokens, :pagination, :boolean
  end
end
