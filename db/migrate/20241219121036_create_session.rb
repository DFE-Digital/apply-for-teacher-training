class CreateSession < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :candidate, null: false, foreign_key: { on_delete: :cascade }
      t.string :ip_address
      t.string :user_agent
      t.string :id_token_hint
      t.string :error_message

      t.timestamps
    end
  end
end
