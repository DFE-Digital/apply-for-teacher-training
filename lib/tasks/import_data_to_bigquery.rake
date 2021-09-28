DEFAULT_BATCH_SIZE = 200
SLEEP_TIME = 2

namespace :bigquery do
  desc 'Import model data to BigQuery as import_entity type events'
  task :import_entity_events, %i[model_name sleep_time batch_size start_at_id] => :environment do |_, args|
    abort('You must specify the model whose data you want to import to BigQuery e.g. rake bigquery:import_entity_events[ApplicationChoice]') if args[:model_name].blank?

    model_name = args[:model_name]
    sleep_time = args.fetch(:sleep_time, SLEEP_TIME).to_i
    batch_size = args.fetch(:batch_size, DEFAULT_BATCH_SIZE).to_i
    id = start_at_id = args[:start_at_id] || 0
    model_class = Object.const_get(model_name)

    model_class.order(:id).where('id > ?', start_at_id).find_in_batches(batch_size: batch_size) do |records|
      records.each do |record|
        id = record.id
        Events::ImportEntityEvent.new(record).send
      end
      sleep sleep_time
    end
  ensure
    Rails.logger.info("Process ended while processing #{model_name} with id: #{id}")
  end
end
