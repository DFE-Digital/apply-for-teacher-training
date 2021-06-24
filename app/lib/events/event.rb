module Events
  class Event
    EVENT_TYPES = %w[web_request].freeze

    def initialize
      @event_hash = {
        environment: HostingEnvironment.environment_name,
        occurred_at: Time.zone.now.iso8601,
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
        request_user_agent: rack_request.user_agent,
        request_method: rack_request.method,
        request_path: rack_request.path,
        request_query: query_to_kv_pairs(rack_request.query_string),
        request_referer: rack_request.referer,
      )

      self
    end

    def with_response_details(rack_response)
      @event_hash.merge!(
        response_content_type: rack_response.content_type,
        response_status: rack_response.status,
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

  private

    def query_to_kv_pairs(query_string)
      vars = Rack::Utils.parse_query(query_string)
      vars.map do |(key, value)|
        { 'key' => key, 'value' => Array.wrap(value) }
      end
    end
  end
end
