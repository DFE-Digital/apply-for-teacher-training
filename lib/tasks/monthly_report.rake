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
  report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new
  report.load_table_data
  report.save!
end

desc 'Write the latest MonthlyStatisticsReport to JSON and a set of CSV files'
task export_monthly_report: :environment do
  stats = Publications::MonthlyStatistics::MonthlyStatisticsReport.last.statistics.to_json
  File.write('monthly_report.json', stats)

  exports = EXPORTS.map do |export|
    export_type = DataExport::EXPORT_TYPES.fetch(export.to_sym)
    DataExport.where(name: export_type.fetch(:name)).order(created_at: :desc).first
  end

  rows = exports.map do |ex|
    ex.as_json.except(%i[initiator_type initiator_id created_at updated_at id])
      .to_json
  end.join("\n")

  File.write('monthly_report_tables.csv', rows)
end

desc 'Import a MonthlyStatisticsReport created by the :export_monthly_report task'
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

desc 'Generate CSVs for a MonthlyStatisticsReport, as of right now'
task generate_monthly_report_csvs: %i[environment] do
  EXPORTS.each do |export|
    export_type = DataExport::EXPORT_TYPES.fetch(export)
    data_export = DataExport.create!(name: export_type.fetch(:name), initiator: SupportUser.first, export_type: export_type.fetch(:export_type))
    DataExporter.new.perform(export_type.fetch(:class).to_s, data_export.id, export_type.fetch(:export_options, {}))
  end
end

desc 'Write the latest monthly report CSVs to files'
task write_monthly_report_csvs: %i[environment build_monthly_report_csvs] do
  folder_name = Rails.root.join('tmp', "export-#{Time.now.to_i}")
  Dir.mkdir(folder_name)

  EXPORTS.each do |export|
    export_type = DataExport::EXPORT_TYPES.fetch(export)
    data_export = DataExport.where(name: export_type.fetch(:name)).order(created_at: :desc).first
    DataExporter.new.perform(export_type.fetch(:class).to_s, data_export.id, export_type.fetch(:export_options, {}))

    filename = "#{folder_name}/#{data_export.filename}"

    File.write(filename, data_export.reload.data.encode('utf-8', invalid: :replace, undef: :replace, replace: '_'))
    puts "wrote #{filename}"
  end
end
