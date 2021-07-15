class SendEventsToBigquery
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :low_priority

  def perform(request_event_json)
    table_name = ENV.fetch('BIG_QUERY_TABLE_NAME', 'events')
    bq = Google::Cloud::Bigquery.new(project: ENV.fetch('BIG_QUERY_PROJECT_ID'))
    dataset = bq.dataset(ENV.fetch('BIG_QUERY_DATASET'), skip_lookup: true)
    bq_table = dataset.table(table_name, skip_lookup: true)
    bq_table.insert([request_event_json])
  end
end
