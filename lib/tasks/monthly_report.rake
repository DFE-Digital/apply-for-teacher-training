EXPORTS = [
  :monthly_statistics_applications_by_course_age_group,
  :monthly_statistics_applications_by_course_type,
  :monthly_statistics_applications_by_primary_specialist_subject,
  :monthly_statistics_applications_by_provider_area,
  :monthly_statistics_applications_by_secondary_subject,
  :monthly_statistics_applications_by_status,
  :monthly_statistics_candidates_by_age_group,
  :monthly_statistics_candidates_by_area,
  :monthly_statistics_candidates_by_sex,
  :monthly_statistics_candidates_by_status,
  # :tad_applications,
].freeze

desc 'Generate a new MonthlyStatisticsReport as of right now'
task run_monthly_report: :environment do
  report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(month: MonthlyStatisticsTimetable.month_to_generate_for.strftime('%Y-%m'))
  report.load_table_data
  report.save!
end

desc 'Write the latest MonthlyStatisticsReport to JSON and a set of CSV files'
task export_monthly_report: :environment do
  stats = Publications::MonthlyStatistics::MonthlyStatisticsReport.last.statistics.to_json
  File.write('monthly_report.json', stats)
end

desc 'Import a MonthlyStatisticsReport created by the :export_monthly_report task'
task import_monthly_report: :environment do
  json = File.read('monthly_report.json')

  raise 'monthly_report.json not found!' if json.blank?

  statistics = JSON.parse(json)
  Publications::MonthlyStatistics::MonthlyStatisticsReport.create!(statistics: statistics)

  puts 'Monthly report import complete!'
end
