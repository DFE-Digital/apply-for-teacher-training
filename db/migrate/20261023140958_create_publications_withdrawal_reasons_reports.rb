class CreatePublicationsWithdrawalReasonsReports < ActiveRecord::Migration[8.1]
  def change
    create_table :withdrawal_reasons_reports do |t|
      t.references :provider, null: false, foreign_key: { on_delete: :cascade }
      t.integer :recruitment_cycle_year, null: false
      t.json :statistics
      t.timestamps

      t.index :recruitment_cycle_year
    end
  end
end
