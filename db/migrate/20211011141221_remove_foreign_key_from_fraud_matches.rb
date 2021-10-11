class RemoveForeignKeyFromFraudMatches < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key 'candidates', 'fraud_matches', validate: false
  end
end
