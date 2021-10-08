class AddBlockedToFraudMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :fraud_matches, :blocked, :boolean, default: false
  end
end
