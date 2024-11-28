class CreateOneLoginAuths < ActiveRecord::Migration[8.0]
  def change
    create_table :one_login_auths do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.references :candidate, null: false, foreign_key: true

      t.timestamps
    end
  end
end
