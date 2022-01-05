class AddResolvedToFraudMatch < ActiveRecord::Migration[6.1]
  def change
    add_column :fraud_matches, :resolved, :boolean, null: false, default: false
  end
end
