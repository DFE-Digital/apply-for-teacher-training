class ValidateAddForeignKeyToFraudMatches < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key 'candidates', 'fraud_matches'
  end
end
