class AddLastUsedAtToVendorApiTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :vendor_api_tokens, :last_used_at, :datetime
  end
end
