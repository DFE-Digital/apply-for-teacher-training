class RemoveSubmittedAtFromFraudMatches < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :fraud_matches, :submitted_at, :datetime }
  end
end
