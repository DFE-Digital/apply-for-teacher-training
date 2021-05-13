module Events
  class Event
    def initialize
      @event_hash = {
        environment: HostingEnvironment.environment_name,
        timestamp: Time.zone.now.iso8601,
      }
    end

    def as_json
      @event_hash.as_json
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
