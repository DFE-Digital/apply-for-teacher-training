TAD_STATUS_MAPPINGS = {
  candidates: :candidates,
  offers: :offer_received,
  accepts: :accepted,
  declined: :application_declined,
  rejections: :application_rejected,
  withdrawals: :application_withdrawn,
}

desc 'Pre-process TAD data to normalise keys and remove unecessary arrays'
task :preprocess_tad_data, [:tad_data_file_name] => [:environment] do |_t, args|
  tad_data = JSON.parse(File.read(args[:tad_data_file_name]))
  File.write(
    args[:tad_data_file_name],
      tad_data.map { |subject, v| [subject.downcase.gsub('&', 'and').gsub('overall', 'total').parameterize.underscore.to_sym, v.map { |status, ids| raise "cannot find #{status}" unless TAD_STATUS_MAPPINGS[status.downcase.to_sym]; [TAD_STATUS_MAPPINGS[status.downcase.to_sym], ids.map { |id| id.is_a?(Array) ? id.first : id }]}.to_h] }.to_h.to_json,
  )
end

desc 'Compare ministerial report data from TAD and Apply and highlight any inconsistencies'
task :compare_ministerial_reports, [:bat_data_file_name, :tad_data_file_name] => :environment do |_t, args|
  bat_data = JSON.parse(File.read(args[:bat_data_file_name]))
  tad_data = JSON.parse(File.read(args[:tad_data_file_name]))

  compare = Publications::CompareMinisterialReports.new(
    bat_data: bat_data,
    tad_data: tad_data,
  )

  diff_data = compare.diff
  File.write(
    "diff-#{Time.zone.now.to_s.gsub(/ \+[\d]+/, '').gsub(' ', '-').gsub(':', '')}.json",
    diff_data.to_json(indent: 2),
  )
end
