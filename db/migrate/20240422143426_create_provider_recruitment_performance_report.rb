class CreateProviderRecruitmentPerformanceReport < ActiveRecord::Migration[7.1]
  def change
    create_table :provider_recruitment_performance_reports do |t|
      t.references :provider, null: false, foreign_key: true
      t.json :statistics
      t.integer :cycle_week, null: false
      t.date :publication_date, null: false
      t.date :generation_date
      t.timestamps
    end
  end
end
