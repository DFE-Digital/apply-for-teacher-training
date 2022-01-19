class RemoveFraudulentFromFraudMatch < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :fraud_matches, :fraudulent, :boolean }
  end
end
