class CreatePublicationsProviderEdiReports < ActiveRecord::Migration[8.0]
  def change
    create_table :provider_edi_reports do |t|
      t.references :provider, null: true, foreign_key: { on_delete: :cascade }
      t.json :statistics
      t.integer :cycle_week, null: false
      t.integer :recruitment_cycle_year, null: false
      t.string :category, null: false
      t.date :publication_date, null: false
      t.date :generation_date
      t.timestamps

      t.index :recruitment_cycle_year
    end
  end
end
