class AddColumnsToVendorTokens < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference(
      :vendor_api_tokens,
      :vendor,
      null: true,
      index: { algorithm: :concurrently },
    )

    add_column :vendor_api_tokens, :in_house_developers, :boolean, default: false, null: false
  end
end
