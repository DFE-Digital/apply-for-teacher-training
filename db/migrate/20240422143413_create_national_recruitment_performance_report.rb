class CreateNationalRecruitmentPerformanceReport < ActiveRecord::Migration[7.1]
  def change
    create_table :national_recruitment_performance_reports do |t|
      t.json :statistics
      t.integer :cycle_week, null: false
      t.date :publication_date, null: false
      t.date :generation_date
      t.timestamps
    end
  end
end
