module EmitRequestEvents
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    after_action :trigger_request_event
  end

  def trigger_request_event
    request_event = Events::Event.new
      .with_request_details(request)
      .with_user_and_namespace(current_user, current_namespace)

    # send event
    SendRequestEventsToBigquery.perform_async(request_event.as_json)
  end
end
