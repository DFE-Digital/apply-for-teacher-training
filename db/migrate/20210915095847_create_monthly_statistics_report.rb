class CreateMonthlyStatisticsReport < ActiveRecord::Migration[6.1]
  def change
    create_table :monthly_statistics_reports do |t|
      t.timestamps
      t.json :statistics
    end
  end
end
