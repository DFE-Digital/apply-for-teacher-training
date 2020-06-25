class CreateAuthenticationTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :authentication_tokens do |t|
      t.bigint :authenticable_id, null: false
      t.string :authenticable_type, null: false
      t.string :hashed_token, null: false
      t.index :hashed_token, unique: true
      t.index %i[authenticable_id authenticable_type], name: 'index_authentication_tokens_on_id_and_type'

      t.timestamps
    end
  end
end
