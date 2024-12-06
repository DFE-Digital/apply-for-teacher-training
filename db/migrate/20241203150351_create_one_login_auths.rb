class CreateOneLoginAuths < ActiveRecord::Migration[8.0]
  def change
    create_table :one_login_auths do |t|
      t.string :email_address, null: false
      t.string :token, null: false
      t.references :candidate, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
