class RemoveInHouseFromVendorTokens < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :vendor_api_tokens, :in_house_developers, :boolean, default: false, null: false
    end
  end
end
