desc 'Import monthly report'
task import_monthly_report: :environment do
  json = File.read('monthly_report.json')

  raise 'monthly_report.json not found!' if json.blank?

  statistics = JSON.parse(json)
  Publications::MonthlyStatistics::MonthlyStatisticsReport.create!(statistics: statistics)

  puts 'Monthly report import complete!'

  File.foreach('monthly_report_tables.csv') do |json_from_file|
    data = JSON.parse(json_from_file)
    support_user = SupportUser.find_by(id: 'duncan.brown@digital.education.gov.uk').presence || SupportUser.last

    data.merge!(initiator_type: 'SupportUser', initiator_id: support_user.id, completed_at: Time.zone.now)

    puts DataExport.create!(data).inspect
  end

  puts 'CSV import complete!'
end
