class AddIndexToProviderUserDfESignInUid < ActiveRecord::Migration[6.0]
  def change
    remove_index :provider_users, :dfe_sign_in_uid
    add_index :provider_users, :dfe_sign_in_uid, unique: true
  end
end
