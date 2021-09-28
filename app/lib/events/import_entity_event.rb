module Events
  class ImportEntityEvent
    attr_accessor :table_name, :event_type, :record

    def initialize(record)
      @table_name = record.class.table_name
      @record = record
      @event_type = 'import_entity'
    end

    def send
      event = Events::Event.new
        .with_type(event_type)
        .with_entity_table_name(table_name)
        .with_data(entity_data(record))

      SendEventsToBigquery.perform_async(event.as_json)
    end

  private

    def entity_data(attributes)
      exportable_attrs = Rails.configuration.analytics[table_name.to_sym].presence || []
      pii_attrs = Rails.configuration.analytics_pii[table_name.to_sym].presence || []
      exportable_pii_attrs = exportable_attrs & pii_attrs

      to_send = attributes.slice(*exportable_attrs&.map(&:to_s))
      to_obfuscate = attributes.slice(*exportable_pii_attrs&.map(&:to_s))

      to_send.deep_merge(to_obfuscate.transform_values { |value| anonymise(value) })
    end

    def anonymise(value)
      Digest::SHA2.hexdigest(value.to_s)
    end
  end
end
