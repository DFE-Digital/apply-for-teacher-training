module APIDocs
  class APIDocsController < ActionController::Base
    include RequestQueryParams
    layout 'application'

  private

    def append_info_to_payload(payload)
      super

      payload.merge!(request_query_params)
    end
  end
end
