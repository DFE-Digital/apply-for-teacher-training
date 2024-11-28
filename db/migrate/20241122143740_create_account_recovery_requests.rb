class CreateAccountRecoveryRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :account_recovery_requests do |t|
      t.integer :code, null: false, index: { unique: true }
      t.references :candidate, null: false, foreign_key: { on_delete: :cascade }
      t.string :previous_account_email, null: false
      t.boolean :successful, default: false

      t.timestamps
    end
  end
end
