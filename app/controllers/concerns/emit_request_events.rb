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

      SendRequestEventsToBigquery.perform_async(request_event.as_json)
    end
  end
end
