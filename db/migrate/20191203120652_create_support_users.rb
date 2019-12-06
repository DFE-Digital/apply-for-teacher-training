class CreateSupportUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :support_users do |t|
      t.string :dfe_sign_in_uid, null: false
      t.timestamps
    end

    add_index :support_users, :dfe_sign_in_uid, unique: true
  end
end
