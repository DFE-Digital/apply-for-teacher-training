# frozen_string_literal: true

module FindInterface
  class FindInterfaceController < ActionController::Base
    before_action :store_request_id
    before_action :assign_sentry_contexts
    layout 'application'

    def store_request_id
      RequestStore.store[:request_id] = request.uuid
    end

    def assign_sentry_contexts
      Raven.tags_context(request_id: RequestStore.store[:request_id])
    end

    def append_info_to_payload(payload)
      super

      payload[:request_id] = RequestStore.store[:request_id]
    end
  end
end
