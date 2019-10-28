class CreateVendorApiUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :vendor_api_users do |t|
      t.string :full_name, null: false
      t.string :email_address, null: false
      t.string :user_id, null: false
      t.references :vendor_api_token, null: false
      t.timestamps
    end

    add_index(
      :vendor_api_users,
      %i[full_name email_address user_id vendor_api_token_id],
      unique: true,
      name: :index_vendor_api_users_on_name_email_userid_token,
    )
  end
end
