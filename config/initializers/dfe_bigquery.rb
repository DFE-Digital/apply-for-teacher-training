require_dependency Rails.root.join('app/lib/dfe/bigquery')

DfE::Bigquery.configure do |config|
  config.bigquery_project_id = ENV.fetch('BIG_QUERY_PROJECT_ID', 'fake_project_id')

  # Retries and timeout (in milliseconds).
  # https://github.com/googleapis/google-api-ruby-client/blob/main/generated/google-apis-bigquery_v2/OVERVIEW.md
  config.bigquery_retries = 2
  config.bigquery_timeout = 10.seconds.in_milliseconds
end
