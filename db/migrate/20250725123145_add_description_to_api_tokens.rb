class AddDescriptionToAPITokens < ActiveRecord::Migration[8.0]
  def change
    add_column :vendor_api_tokens, :description, :string
  end
end
