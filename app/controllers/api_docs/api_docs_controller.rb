module APIDocs
  class APIDocsController < ActionController::Base
    include LogQueryParams
    layout 'application'

  private

    def append_info_to_payload(payload)
      super

      payload.merge!(log_query_params)
    end
  end
end
