class AddMonthToMonthlyStatisticsReports < ActiveRecord::Migration[6.1]
  def change
    add_column :monthly_statistics_reports, :month, :string
  end
end
