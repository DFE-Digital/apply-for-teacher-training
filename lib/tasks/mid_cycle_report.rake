desc 'Ingest provider-specific mid-cycle report from a CSV file'
task :ingest_provider_report, %i[import_path publication_date] => [:environment] do |_t, args|
  # bundle exec rake ingest_provider_report\[path_to_file.csv, yyyy-mm-dd\]
  # bundle exec rake "ingest_provider_report[mid_cycle_report_table_provider_level.csv,2023-05-09]"
  import_path = args[:import_path]
  publication_date = Date.parse(args[:publication_date])
  csv = CSV.read(import_path, headers: true)
  Publications::ProviderMidCycleReport.ingest(csv, publication_date)
end
