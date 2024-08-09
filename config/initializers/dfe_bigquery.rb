require_dependency Rails.root.join('app/lib/dfe/bigquery')

DfE::Bigquery.configure do |config|
  config.bigquery_project_id = ENV.fetch('BIG_QUERY_PROJECT_ID', 'fake_project_id')

  # Retries and timeout (in seconds). See
  # https://github.com/googleapis/google-cloud-ruby/blob/main/google-cloud-bigquery/OVERVIEW.md#configuring-retries-and-timeout
  config.bigquery_retries = 2
  config.bigquery_timeout = 10
end
