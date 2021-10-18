DEFAULT_BATCH_SIZE = 200
SLEEP_TIME = 2
IRREGULAR_TABLE_NAMES = {
  provider_relationship_permissions: 'ProviderRelationshipPermissions',
  provider_user_notifications: 'ProviderUserNotificationPreferences',
  provider_users_providers: 'ProviderPermissions',
  references: 'ApplicationReference',
  chasers_sent: 'ChaserSent',
}.freeze

def entity_models
  Rails.configuration.analytics.merge(Rails.configuration.analytics_pii).map do |table_name, _|
    IRREGULAR_TABLE_NAMES[table_name.to_sym] || table_name.to_s.classify
  end
end

namespace :bigquery do
  desc 'Import all entity events to BigQuery'
  task :import_all_entity_events, %i[sleep_time batch_size] do |_, args|
    sleep_time = args.fetch(:sleep_time, SLEEP_TIME).to_i
    batch_size = args.fetch(:batch_size, DEFAULT_BATCH_SIZE).to_i

    entity_models.each do |model_name|
      Rake::Task['bigquery:import_entity_events'].invoke(model_name,
                                                         sleep_time,
                                                         batch_size)
      Rake::Task['bigquery:import_entity_events'].reenable
    end
  end

  desc 'Import model data to BigQuery as import_entity type events'
  task :import_entity_events, %i[model_name sleep_time batch_size start_at_id] => :environment do |_, args|
    abort('You must specify the model whose data you want to import to BigQuery e.g. rake bigquery:import_entity_events[ApplicationChoice]') if args[:model_name].blank?

    model_name = args[:model_name]
    sleep_time = args.fetch(:sleep_time, SLEEP_TIME).to_i
    batch_size = args.fetch(:batch_size, DEFAULT_BATCH_SIZE).to_i
    id = start_at_id = args[:start_at_id] || 0
    model_class = Object.const_get(model_name)

    Rails.logger.info("Processing data for #{model_name} with row count #{model_class.count}")

    model_class.order(:id).where('id > ?', start_at_id).find_in_batches(batch_size: batch_size) do |records|
      id = records.first.id
      Bigquery::ImportEntityEvents.new(records).call
      sleep sleep_time
    end
  ensure
    Rails.logger.info("Process ended while processing #{model_name} within the id range #{id} to #{id + batch_size}")
  end
end
