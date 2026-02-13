class CreatePublicationsEdiReports < ActiveRecord::Migration[8.0]
  def change
    create_table :regional_edi_reports do |t|
      t.json :statistics
      t.integer :cycle_week, null: false
      t.integer :recruitment_cycle_year, null: false
      t.string :region, null: false
      t.string :category, null: false
      t.date :publication_date, null: false
      t.date :generation_date
      t.timestamps

      t.index :recruitment_cycle_year
    end
  end
end
