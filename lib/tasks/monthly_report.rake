desc 'Generate a new MonthlyStatisticsReport as of right now'
task run_monthly_report: :environment do
  report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(month: MonthlyStatisticsTimetable.month_to_generate_for.strftime('%Y-%m'))
  report.load_table_data
  report.save!
end

desc 'Write the latest MonthlyStatisticsReport to JSON and a set of CSV files'
task export_monthly_report: :environment do
  Publications::MonthlyStatistics::JSONExport.new('monthly_report.json').export!
end

desc 'Import a MonthlyStatisticsReport created by the :export_monthly_report task'
task import_monthly_report: :environment do
  month = MonthlyStatisticsTimetable.month_to_generate_for.strftime('%Y-%m')
  Publications::MonthlyStatistics::JSONExport.new('monthly_report.json').import!(month)
end
