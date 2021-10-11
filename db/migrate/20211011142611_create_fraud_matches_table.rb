class CreateFraudMatchesTable < ActiveRecord::Migration[6.1]
  def change
    create_table :fraud_matches do |t|
      t.datetime :candidate_last_contacted_at
      t.integer :recruitment_cycle_year
      t.string :last_name
      t.date :date_of_birth
      t.string :postcode
      t.boolean :fraudulent, default: false
      t.boolean :blocked, default: false

      t.timestamps
    end

    add_foreign_key :candidates, :fraud_matches, validate: false
  end
end

class ValidateCreateFraudMatchesTable < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :candidates, :fraud_match
  end
end
