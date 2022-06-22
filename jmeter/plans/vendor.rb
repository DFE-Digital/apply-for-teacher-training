require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')
WAIT_FACTOR = ENV.fetch('JMETER_WAIT_FACTOR', 1).to_f
RAMPUP = ENV.fetch('JMETER_RAMPUP', 0).to_i
API_VERSION = ENV.fetch('API_VERSION', 'v1.0')

def since
  # 90 days ago
  days_ago = 90 * 24 * 60 * 60
  (Time.now.utc - days_ago).strftime('%Y-%m-%dT%H:%M:%S.%L%z')
end

def request_headers(api_key)
  header [
    { name: 'Content-Type', value: 'application/json' },
    { name: 'Authorization', value: "Bearer #{api_key}" },
  ]
end

def request_params
  request_params = { since: since }
  request_params.merge!(per_page: 50, page: 1) unless API_VERSION == 'v1.0'
  request_params
end

def vendor_api_keys
  filepath = 'plans/vendor_api_keys.txt'
  raise "No load test API keys found in #{filepath}. (#{Dir.pwd})" unless File.exist?(filepath)

  File.read(filepath).split
end

# Expected Oct usage per hour:
#   71 SRS systems polling every hour for 90 days of data
test do
  random_timer 1000, 900000 * WAIT_FACTOR # this is 4x that

  vendor_api_keys.each do |api_key|
    # Sync applications (last 90 days) once every hour
    threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 3600 do
      request_headers(api_key)

      get(
        name: 'API Sync applications',
        url: "#{BASEURL}/api/#{API_VERSION}/applications",
        raw_body: request_params.to_json { with_xhr },
      )
    end

    # Make offer
    threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 3600 do
      request_headers(api_key)

      get(
        name: 'API Sync applications',
        url: "#{BASEURL}/api/#{API_VERSION}/applications",
        raw_body: request_params.to_json do
          extract name: 'last_application_id', json: '$.data[-1].id'
          with_xhr
        end,
      )

      offer_payload = {
        data: {
          conditions: [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
        meta: {
          attribution: {
            full_name: 'Jane Smith',
            email: 'jane.smith@example.com',
            user_id: '12345',
          },
          timestamp: since,
        },
      }

      submit(
        name: 'API Make offer',
        url: "#{BASEURL}/api/#{API_VERSION}/applications/${last_application_id}/offer",
        raw_body: offer_payload.to_json { with_xhr },
      )
    end
  end
end.jmx
