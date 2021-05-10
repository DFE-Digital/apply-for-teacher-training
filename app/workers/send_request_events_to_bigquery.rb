class SendRequestEventsToBigquery
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :low_priority

  TABLE_NAME = 'events'.freeze

  def perform(request_event_json)
    bq = Google::Cloud::Bigquery.new(project: ENV.fetch('BIG_QUERY_PROJECT_ID'))
    dataset = bq.dataset(ENV.fetch('BIG_QUERY_DATASET'), skip_lookup: true)
    bq_table = dataset.table(TABLE_NAME, skip_lookup: true)
    bq_table.insert([request_event_json])
  end
end
