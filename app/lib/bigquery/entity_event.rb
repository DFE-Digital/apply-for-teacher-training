module Bigquery
  class EntityEvent
    attr_accessor :record, :table_name, :event_type

    def initialize(record, event_type)
      @record = record
      @table_name = record.class.table_name
      @event_type = event_type
    end

    def to_event
      Events::Event.new
        .with_type(event_type)
        .with_entity_table_name(table_name)
        .with_data(entity_data(record, table_name))
    end

  private

    def entity_data(attributes, table_name)
      exportable_attrs = Rails.configuration.analytics[table_name.to_sym].presence || []
      pii_attrs = Rails.configuration.analytics_pii[table_name.to_sym].presence || []
      exportable_pii_attrs = exportable_attrs & pii_attrs

      allowed_attributes = attributes.slice(*exportable_attrs&.map(&:to_s))
      obfuscated_attributes = attributes.slice(*exportable_pii_attrs&.map(&:to_s))

      allowed_attributes.deep_merge(obfuscated_attributes.transform_values { |value| anonymise(value) })
    end

    def anonymise(value)
      Digest::SHA2.hexdigest(value.to_s)
    end
  end
end
