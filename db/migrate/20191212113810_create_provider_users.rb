class CreateProviderUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :provider_users do |t|
      t.string :email_address, null: false
      t.string :dfe_sign_in_uid, null: false
    end

    add_index :provider_users, :dfe_sign_in_uid, unique: true
  end
end
