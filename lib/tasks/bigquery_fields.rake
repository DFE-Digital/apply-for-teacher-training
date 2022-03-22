namespace :bigquery do
  desc 'Generate a new field blocklist containing all the fields not listed for sending to Bigquery'
  task regenerate_blocklist: :environment do
    File.write(
      Rails.root.join('config/analytics_blocklist.yml'),
      { shared: Bigquery::FieldList.generate_blocklist }.to_yaml,
    )
  end
end
