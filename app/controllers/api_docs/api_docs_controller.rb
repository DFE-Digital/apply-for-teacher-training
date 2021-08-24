module APIDocs
  class APIDocsController < ActionController::Base
    include RequestQueryParams
    layout 'application'

  private

    def append_info_to_payload(payload)
      super

      payload.merge!(query_params: request_query_params)
    end
  end
end
