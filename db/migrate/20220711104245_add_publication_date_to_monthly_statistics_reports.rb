class AddPublicationDateToMonthlyStatisticsReports < ActiveRecord::Migration[7.0]
  def change
    add_column :monthly_statistics_reports, :publication_date, :date
  end
end
