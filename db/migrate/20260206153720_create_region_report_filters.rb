class CreateRegionReportFilters < ActiveRecord::Migration[8.0]
  def change
    create_table :regional_report_filters do |t|
      t.references :provider_user, null: true, foreign_key: { on_delete: :cascade }
      t.references :provider, null: true, foreign_key: { on_delete: :cascade }
      t.string :region, null: false

      t.timestamps
    end
  end
end
