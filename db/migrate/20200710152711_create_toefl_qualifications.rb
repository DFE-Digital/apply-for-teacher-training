class CreateToeflQualifications < ActiveRecord::Migration[6.0]
  def change
    create_table :toefl_qualifications do |t|
      t.string :registration_number, null: false
      t.integer :total_score, null: false
      t.integer :award_year, null: false

      t.timestamps
    end
  end
end
