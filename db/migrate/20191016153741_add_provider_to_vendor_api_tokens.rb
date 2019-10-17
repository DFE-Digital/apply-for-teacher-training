class AddProviderToVendorApiTokens < ActiveRecord::Migration[6.0]
  def up
    execute 'TRUNCATE vendor_api_tokens'
    add_reference :vendor_api_tokens, :provider, null: false, foreign_key: { on_delete: :cascade }
  end

  def down
    remove_column :vendor_api_tokens, :provider_id
  end
end
