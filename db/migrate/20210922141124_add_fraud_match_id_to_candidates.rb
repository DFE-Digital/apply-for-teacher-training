class AddFraudMatchIdToCandidates < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :candidates, :fraud_match, index: { algorithm: :concurrently }
  end
end
