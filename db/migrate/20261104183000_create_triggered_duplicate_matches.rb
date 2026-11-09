class CreateTriggeredDuplicateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :triggered_duplicate_matches do |t|
      t.string :last_name
      t.date :date_of_birth
      t.string :postcode
      t.integer :recruitment_cycle_year
      t.timestamps

      t.index %i[date_of_birth last_name], name: 'index_triggered_duplicate_matches_on_dob_and_last_name'
    end
  end
end
