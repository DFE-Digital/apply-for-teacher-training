class ChangeIndexesForProviderUsers < ActiveRecord::Migration[6.0]
  def change
    add_index :provider_users, :email_address, unique: true
    change_column :provider_users, :dfe_sign_in_uid, :string, null: true
    remove_index :provider_users, :dfe_sign_in_uid
    add_index :provider_users, :dfe_sign_in_uid
  end
end
