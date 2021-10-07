class AddForeignKeyToFraudMatches < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key 'candidates', 'fraud_matches', validate: false
  end
end
