class SendEventsToBigquery
  include Sidekiq::Worker
  include RescueEnqueueErrors

  sidekiq_options retry: 3, queue: :big_query

  def perform(events)
    table_name = ENV.fetch('BIG_QUERY_TABLE_NAME', 'events')
    bq = Google::Cloud::Bigquery.new(project: ENV.fetch('BIG_QUERY_PROJECT_ID'), retries: 3, timeout: 120)
    dataset = bq.dataset(ENV.fetch('BIG_QUERY_DATASET'), skip_lookup: true)
    bq_table = dataset.table(table_name, skip_lookup: true)
    response = bq_table.insert(events)

    Sentry.capture_message("SendEventsToBigquery: #{response} data: #{events}") if !response.success?
  end
end
