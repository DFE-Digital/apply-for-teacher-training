module Events
  class Event
    EVENT_TYPES = %w[web_request].freeze

    def initialize
      @event_hash = {
        environment: HostingEnvironment.environment_name,
        timestamp: Time.zone.now.iso8601,
      }
    end

    def as_json
      @event_hash.as_json
    end

    def with_type(type)
      raise 'Invalid analytics event type' unless EVENT_TYPES.include?(type.to_s)

      @event_hash.merge!(
        type: type,
      )

      self
    end

    def with_request_details(rack_request)
      @event_hash.merge!(
        request_uuid: rack_request.uuid,
        request_path: rack_request.path,
        request_method: rack_request.method,
      )

      self
    end

    def with_user_and_namespace(user, namespace)
      @event_hash.merge!(
        namespace: namespace,
        user_id: user&.id,
      )

      self
    end
  end
end
