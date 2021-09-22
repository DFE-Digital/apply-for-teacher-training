module EntityEvents
  extend ActiveSupport::Concern

  included do
    attr_accessor :event_tags

    after_create do
      data = entity_data(attributes)
      send_event('create_entity', data) if data.any?
    end

    after_destroy do
      data = entity_data(attributes)
      send_event('delete_entity', data) if data.any?
    end

    after_update do
      # in this after_update hook we don’t have access to the new fields via
      # #attributes — we need to dig them out of saved_changes which stores
      # them in the format { attr: ['old', 'new'] }
      interesting_changes = entity_data(saved_changes.transform_values(&:last))

      if interesting_changes.any?
        send_event('update_entity', entity_data(attributes).merge(interesting_changes))
      end
    end
  end

  def send_event(type, data)
    return unless FeatureFlag.active?(:send_request_data_to_bigquery)

    event = Events::Event.new
      .with_type(type)
      .with_entity_table_name(self.class.table_name)
      .with_data(data)
      .with_tags(event_tags)
      .with_request_uuid(RequestLocals.fetch(:request_id) { nil })

    SendEventsToBigquery.perform_async(event.as_json)
  end

  def entity_data(changeset)
    exportable_attrs = Rails.configuration.analytics[self.class.table_name.to_sym].presence || []
    pii_attrs = Rails.configuration.analytics_pii[self.class.table_name.to_sym].presence || []
    exportable_pii_attrs = exportable_attrs & pii_attrs

    to_send = changeset.slice(*exportable_attrs&.map(&:to_s))
    to_obfuscate = changeset.slice(*exportable_pii_attrs&.map(&:to_s))

    to_send.deep_merge(to_obfuscate.transform_values { |value| anonymise(value) })
  end

  def anonymise(value)
    Digest::SHA2.hexdigest(value.to_s)
  end
end
