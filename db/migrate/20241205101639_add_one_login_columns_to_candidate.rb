class AddOneLoginColumnsToCandidate < ActiveRecord::Migration[8.0]
  def change
    add_column :candidates, :account_recovery_status, :string, null: false, default: 'not_started'
  end
end
