DfE::Analytics.configure do |config|
  # Whether to log events instead of sending them to BigQuery.
  #
  config.log_only = false

  # Whether to use ActiveJob or dispatch events immediately.
  #
  # config.async = true

  # Which ActiveJob queue to put events on
  #
  config.queue = :big_query

  # The name of the BigQuery table we’re writing to.
  #
  config.bigquery_table_name = 'events'

  # The name of the BigQuery project we’re writing to.
  #
  config.bigquery_project_id = ENV['BIG_QUERY_PROJECT_ID']

  # The name of the BigQuery dataset we're writing to.
  #
  config.bigquery_dataset = ENV['BIG_QUERY_DATASET']

  # Service account JSON key for the BigQuery API. See
  # https://cloud.google.com/bigquery/docs/authentication/service-account-file
  #
  config.bigquery_api_json_key = ENV['BIG_QUERY_API_JSON_KEY']

  # Enables the EntityTableCheckJob
  config.entity_table_checks_enabled = true

  # Passed directly to the retries: option on the BigQuery client
  #
  # config.bigquery_retries = 3

  # Passed directly to the timeout: option on the BigQuery client
  #
  # config.bigquery_timeout = 120

  # A proc which returns true or false depending on whether you want to
  # enable analytics. You might want to hook this up to a feature flag or
  # environment variable.
  #
  config.enable_analytics = proc { FeatureFlag.active?(:send_request_data_to_bigquery) }

  # The environment we’re running in. This value will be attached
  # to all events we send to BigQuery.
  #
  config.environment = HostingEnvironment.environment_name

  # Schedule a maintenance window during which no events are streamed to BigQuery
  # in the format of '22-01-2024 19:30..22-01-2024 20:30' (UTC).
  config.bigquery_maintenance_window = '05-06-2024 18:15..05-06-2024 18:30'
end
