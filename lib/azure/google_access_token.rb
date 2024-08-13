module Azure
  class GoogleAccessToken
    def initialize(sts_token)
      @sts_token = sts_token
      @conn = Faraday.new do |b|
        b.response :json
        b.request :url_encoded
      end
      @url = Azure.config.google_cloud_credentials[:service_account_impersonation_url]
    end

    def call
      access_token_response = @conn.post(@url, request_body, headers)

      access_token_response.success? || raise_error(access_token_response.status, access_token_response.body)

      [access_token_response.body['accessToken'], access_token_response.body['expireTime']]
    end

    def request_body
      { scope: Azure.config.gcp_scope }
    end

    def headers
      { 'Authorization' => "Bearer #{@sts_token}" }
    end

    def raise_error(status, body)
      error = GoogleAPIError.new(status:, body:)

      Rails.logger.error error.detailed_message

      raise error
    end
  end
end
