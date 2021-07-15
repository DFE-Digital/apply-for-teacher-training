require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')

def set_headers(api_key)
  header [
    { name: 'Content-Type', value: 'application/json' },
    { name: 'Authorization', value: "Bearer #{api_key}" },
  ]
end

# Expected Oct usage per hour:
#   71 SRS systems polling every hour for 90 days of data
test do
  # Section below must have 71 api keys, each belonging to a different provider
  %w[
    Xp9jU2_2BeDqsRP8Yy8C
  ].each do |api_key|

    # Sync applications (last 90 days) once every hour
    threads count: 1, continue_forever: true, duration: 3600 do
      set_headers api_key

      params = { since: (Time.now - 7776000).strftime('%Y-%m-%dT%H:%M:%S.%L%z') }
      visit name: 'API Sync applications',
        url: BASEURL + '/api/v1/applications',
        raw_body: params.to_json do
          with_xhr
        end

      think_time 1800000
    end

    # Make offer
    threads count: 1, continue_forever: true, duration: 3600 do
      set_headers api_key

      params = { since: (Time.now - 7776000).strftime('%Y-%m-%dT%H:%M:%S.%L%z') }
      visit name: 'API Sync applications',
        url: BASEURL + '/api/v1/applications',
        raw_body: params.to_json do
          extract name: 'last_application_id', json: '$.data[-1].id'
          with_xhr
        end

      offer_payload = {
        data: {
          conditions: [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test'
          ]
        },
        meta: {
          attribution: {
            full_name: 'Jane Smith',
            email: 'jane.smith@example.com',
            user_id: '12345'
          },
          timestamp: (Time.now - 7776000).strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        }
      }

      submit name: 'API Make offer',
        url: BASEURL + '/api/v1/applications/${last_application_id}/offer',
        raw_body: offer_payload.to_json do
          with_xhr
        end

      think_time 30000
    end
  end
end.jmx
