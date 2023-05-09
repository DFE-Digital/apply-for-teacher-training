class CreateProviderMidCycleReport < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_mid_cycle_reports do |t|
      t.json :statistics
      t.date :publication_date
      t.references :provider, null: false, foreign_key: true

      t.timestamps
    end
  end
end
