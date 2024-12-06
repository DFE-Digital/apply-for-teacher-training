class CreateAccountRecoveryRequestCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :account_recovery_request_codes do |t|
      t.string :hashed_code, null: false
      t.references :account_recovery_request, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
