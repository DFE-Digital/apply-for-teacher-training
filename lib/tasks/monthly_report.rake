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
  :tad_applications,
].freeze

task generate_monthly_report_for_qa: %i[environment] do
  puts 'Generating reports'
  folder_name = Rails.root.join('tmp', "export-#{Time.now.to_i}")
  Dir.mkdir(folder_name)

  EXPORTS.each do |export|
    export_type = DataExport::EXPORT_TYPES.fetch(export)
    data_export = DataExport.create!(name: export_type.fetch(:name), initiator: SupportUser.first, export_type: export_type.fetch(:export_type))
    DataExporter.new.perform(export_type.fetch(:class).to_s, data_export.id, export_type.fetch(:export_options, {}))

    filename = "#{folder_name}/#{data_export.filename}"

    File.write(filename, data_export.reload.data.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_'))
    puts "wrote #{filename}"
  end
end
