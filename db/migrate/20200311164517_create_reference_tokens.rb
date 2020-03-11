class CreateReferenceTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :reference_tokens do |t|
      t.references :application_reference, null: false, foreign_key: { to_table: :references, on_delete: :cascade }

      t.string :hashed_token, null: false
      t.index :hashed_token, unique: true

      t.timestamps
    end
  end
end
