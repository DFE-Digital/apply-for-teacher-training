module WorkloadIdentityFederation
  class UserCredentials
    ACCESS_TOKEN_EXPIRE_TIME_LEEWAY = 10.seconds

    def self.call
      return @gcp_client_credentials if @gcp_client_credentials && !@gcp_client_credentials.expired?

      azure_token = AzureAccessToken.new.call
      sts_token = GoogleTokenExchange.new(azure_token).call
      google_token, expire_time = GoogleAccessToken.new(sts_token).call

      @gcp_client_credentials = Google::Auth::UserRefreshCredentials.new(access_token: google_token, expires_at: expire_time.to_datetime - ACCESS_TOKEN_EXPIRE_TIME_LEEWAY)
    end
  end
end
