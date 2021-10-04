module Bigquery
  class EntityEvent
    include BigqueryDataConversion

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
  end
end
