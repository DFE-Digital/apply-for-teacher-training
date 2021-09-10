module EmitRequestEvents
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    after_action :trigger_request_event
  end

  def trigger_request_event
    if FeatureFlag.active?(:send_request_data_to_bigquery)
      request_event = Events::Event.new
        .with_type('web_request')
        .with_request_details(request)
        .with_response_details(response)
        .with_user_and_namespace(current_user, current_namespace)

      EM.next_tick do
        attempt_count = 0
        begin
          attempt_count += 1
          SendEventsToBigquery.perform_async(request_event.as_json)
        rescue Redis::CommandError
          abort if attempt_count > 5
          wait_time = 2 ** (attempt_count + 1)
          puts "Waiting #{wait_time} seconds to SendEventsToBigquery..."
          sleep wait_time
          retry
        end
      end
    end
  end
end
