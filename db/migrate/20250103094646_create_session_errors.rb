class CreateSessionErrors < ActiveRecord::Migration[8.0]
  def change
    create_table :session_errors do |t|
      t.references :candidate, null: true, foreign_key: { on_delete: :cascade }
      t.string :id_token_hint
      t.string :body
      t.json :omniauth_hash

      t.timestamps
    end
  end
end
