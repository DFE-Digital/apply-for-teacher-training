class CreateVendorApiTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :vendor_api_tokens do |t|
      t.string :hashed_token, null: false
      t.index :hashed_token, unique: true
      t.timestamps
    end
  end
end
