module EntityEvents
  extend ActiveSupport::Concern

  included do
    attr_accessor :event_tags

    after_create do
      data = entity_data(attributes)
      send_event('entity_created', data) if data.any?
    end
  end

  def send_event(type, data)
    event = Events::Event.new
      .with_type(type)
      .with_data(default_entity_data.merge(data))
      .with_tags(event_tags)

    SendEventsToBigquery.perform_async(event.as_json)
  end

  def entity_data(changeset)
    exportable_attrs = Rails.configuration.analytics[self.class.table_name.to_sym]
    changeset.slice(*exportable_attrs&.map(&:to_s))
  end

  def default_entity_data
    { table_name: self.class.table_name }
  end
end
