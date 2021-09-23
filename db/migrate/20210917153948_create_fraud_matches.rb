class CreateFraudMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :fraud_matches do |t|
      t.datetime :candidate_last_contacted_at
      t.integer :recruitment_cycle_year
      t.string :last_name
      t.date :date_of_birth
      t.string :postcode
      t.boolean :fraudulent?
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
