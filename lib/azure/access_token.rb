module Azure
  class AccessToken
    def initialize
      @url = Azure.config.google_cloud_credentials[:credential_source][:url]
      @conn = Faraday.new do |b|
        b.response :json
        b.request :url_encoded
      end
    end

    def call
      azure_token_response = @conn.get(@url) do |req|
        req.body = request_body
      end

      unless azure_token_response.success?
        error = AzureAPIError.new(status: azure_token_response.status, body: azure_token_response.body)
        Rails.logger.error error.detailed_message

        raise error
      end

      azure_token_response.body['access_token']
    end

    def request_body
      begin
        client_assertion = File.read(Azure.config.azure_token_file_path)
      rescue Errno::ENOENT
        raise AzureTokenFilePathError
      end

      {
        grant_type: 'client_credentials',
        client_id: Azure.config.azure_client_id,
        scope: Azure.config.azure_scope,
        client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
        client_assertion:,
      }
    end
  end
end
