module Events
  class ImportEntityEvents
    attr_accessor :table_name, :event_type, :records

    def initialize(records)
      @table_name = records.first.class.table_name
      @records = records
      @event_type = 'import_entity'
    end

    def send
      events = records.map do |record|
        Events::Event.new
          .with_type(event_type)
          .with_entity_table_name(table_name)
          .with_data(entity_data(record))
      end

      SendEventsToBigquery.perform_async(events.as_json)
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
