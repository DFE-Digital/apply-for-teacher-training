desc 'Ingest national-specific mid-cycle report from a CSV file'
task :ingest_national_report, %i[import_path publication_date] => [:environment] do |_t, args|
  # bundle exec rake ingest_national_report\[path_to_file.csv, yyyy-mm-dd\]
  # bundle exec rake "ingest_national_report[mid_cycle_report_table_national_level.csv,2023-05-09]"
  import_path = args[:import_path]
  publication_date = Date.parse(args[:publication_date])
  csv = CSV.read(import_path, headers: true)
  Publications::NationalMidCycleReport.ingest(csv, publication_date)
end
