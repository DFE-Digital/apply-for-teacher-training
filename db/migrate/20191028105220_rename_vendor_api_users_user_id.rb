class RenameVendorApiUsersUserId < ActiveRecord::Migration[6.0]
  def change
    rename_column :vendor_api_users, :user_id, :vendor_user_id
  end
end
