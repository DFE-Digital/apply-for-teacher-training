class CreateNationalMidCycleReport < ActiveRecord::Migration[7.0]
  def change
    create_table :national_mid_cycle_reports do |t|
      t.json :statistics
      t.date :publication_date

      t.timestamps
    end
  end
end
