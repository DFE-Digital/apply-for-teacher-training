class RenameAccountRecoveryRequestCodeColumn < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      add_column :account_recovery_request_codes, :code_digest, :string, null: false
      remove_column :account_recovery_request_codes, :hashed_code, :string, null: false
    end
  end
end
