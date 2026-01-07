class CreateDsiSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :dsi_sessions do |t|
      t.references :user, polymorphic: true, null: false
      t.references :impersonated_provider_user, null: true
      t.string :email_address
      t.string :dfe_sign_in_uid
      t.string :first_name
      t.string :last_name
      t.datetime :last_active_at
      t.string :id_token
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
