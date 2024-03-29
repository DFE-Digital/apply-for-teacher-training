require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')
WAIT_FACTOR = ENV.fetch('JMETER_WAIT_FACTOR', 1).to_f
RAMPUP = ENV.fetch('JMETER_RAMPUP', 0).to_i
API_VERSION = ENV.fetch('API_VERSION', 'v1.0')
THREAD_COUNT = ENV.fetch('JMETER_THREAD_COUNT', 2).to_i

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
    threads count: (THREAD_COUNT / 2), rampup: RAMPUP, continue_forever: true, duration: 3600 do
      request_headers(api_key)

      get(
        name: 'API Sync applications',
        url: "#{BASEURL}/api/#{API_VERSION}/applications",
        raw_body: request_params.to_json { with_xhr },
      ) do
        extract name: 'total_count', json: '$.meta.total_count'
      end

      # Step through a couple of pages of results if we have them.
      if API_VERSION != 'v1.0'
        if_controller(name: 'Page 2 if present', condition: '${__groovy((vars.get("total_count").toInteger() / 50) > 1)}') do
          get(
            name: 'API Sync applications page 2',
            url: "#{BASEURL}/api/#{API_VERSION}/applications",
            raw_body: request_params.merge(page: 2).to_json { with_xhr },
          )

          if_controller(name: 'Page 3 if present', condition: '${__groovy((vars.get("total_count").toInteger() / 50) > 2)}') do
            get(
              name: 'API Sync applications page 3',
              url: "#{BASEURL}/api/#{API_VERSION}/applications",
              raw_body: request_params.merge(page: 3).to_json { with_xhr },
            )
          end
        end
      end
    end

    # Make offer
    threads count: (THREAD_COUNT / 2), rampup: RAMPUP, continue_forever: true, duration: 3600 do
      request_headers(api_key)

      get(
        name: 'API Sync applications',
        url: "#{BASEURL}/api/#{API_VERSION}/applications",
        raw_body: request_params.to_json { with_xhr },
      ) do
        json_path_postprocessor(
          referenceNames: 'last_application_id',
          jsonPathExprs: '$.data[?(@.attributes.status=~/awaiting_provider_decision|interviewing|offer|offer_withdrawn|rejected/)].id',
          match_numbers: 0,
        )
      end

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
