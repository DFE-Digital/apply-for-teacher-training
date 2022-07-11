class AddGenerationDateToMonthlyStatisticsReports < ActiveRecord::Migration[7.0]
  def change
    add_column :monthly_statistics_reports, :generation_date, :date
  end
end
