class CreateIeltsQualifications < ActiveRecord::Migration[6.0]
  def change
    create_table :ielts_qualifications do |t|
      t.string :trf_number, null: false
      t.string :band_score, null: false
      t.integer :award_year, null: false

      t.timestamps
    end
  end
end
