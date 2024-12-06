class CreateAccountRecoveryRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :account_recovery_requests do |t|
      t.string :previous_account_email_address
      t.references :candidate, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
