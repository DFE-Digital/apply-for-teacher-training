desc "Import monthly report CSVs from monthly_report.csv"
task import_monthly_report_csvs: :environment do
  filename = './monthly_report.csv'

  File.foreach(filename) do |json|
    data = JSON.parse(json)
    support_user = SupportUser.find_by(id: 'duncan.brown@digital.education.gov.uk').presence || SupportUser.last

    data.merge!(initiator_type: 'SupportUser', initiator_id: support_user.id, completed_at: Time.zone.now)

    puts DataExport.create!(data).inspect
  end
end

