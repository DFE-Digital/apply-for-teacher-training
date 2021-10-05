module Bigquery
  class ImportEntityEvents
    attr_accessor :event_type, :records

    def initialize(records)
      @records = records
      @event_type = 'import_entity'
    end

    def call
      SendEventsToBigquery.perform_async(events.as_json)
    end

  private

    def events
      records.map { |record| Bigquery::EntityEvent.new(record, event_type).to_event }
    end
  end
end
