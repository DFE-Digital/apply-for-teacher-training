module Azure
  class GoogleTokenExchange
    def initialize(azure_token)
      @azure_token = azure_token
      @conn = Faraday.new do |b|
        b.response :json
        b.request :url_encoded
      end
      @url = Azure.config.google_cloud_credentials[:token_url]
    end

    def call
      token_exchange_response = @conn.post(@url, request_body)

      if token_exchange_response.success?
        token_exchange_response.body['access_token']
      else
        raise_error(token_exchange_response.status, token_exchange_response.body)
      end
    end

    def request_body
      {
        grant_type: 'urn:ietf:params:oauth:grant-type:token-exchange',
        audience: Azure.config.google_cloud_credentials[:audience],
        scope: Azure.config.gcp_scope,
        requested_token_type: 'urn:ietf:params:oauth:token-type:access_token',
        subject_token: @azure_token,
        subject_token_type: Azure.config.google_cloud_credentials[:subject_token_type],
      }
    end

    def raise_error(status, body)
      error = STSAPIError.new(status:, body:)

      Rails.logger.error error.detailed_message

      raise error
    end
  end
end
