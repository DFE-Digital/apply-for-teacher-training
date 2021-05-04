class SendRequestEventsToBigquery
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :low_priority

  TABLE_NAME = 'bat_apply_request_events'.freeze

  def perform(request_event_json)
    big_query_project_id = ENV['BIG_QUERY_PROJECT_ID']
    big_query_dataset = ENV['BIG_QUERY_DATASET']

    if big_query_project_id.present? && big_query_dataset.present?
      bq = Google::Cloud::Bigquery.new(project: big_query_project_id)
      dataset = bq.dataset(big_query_dataset, skip_lookup: true)
      bq_table = dataset.table(TABLE_NAME, skip_lookup: true)
      bq_table.insert([request_event_json])
    end
  end
end
