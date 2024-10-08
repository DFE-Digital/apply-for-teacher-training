Rails.application.config.to_prepare do
  WorkloadIdentityFederation.configure do |config|
    begin
      google_cloud_credentials = JSON.parse(ENV.fetch('GOOGLE_CLOUD_CREDENTIALS_STATS', '{}')).deep_symbolize_keys
    rescue TypeError
      raise WorkloadIdentityFederation::GoogleCloudCredentialsError
    end

    config.azure_client_id = ENV['AZURE_CLIENT_ID']
    config.azure_token_file_path = ENV['AZURE_FEDERATED_TOKEN_FILE']
    config.google_cloud_credentials = google_cloud_credentials
    config.azure_scope = 'api://AzureADTokenExchange/.default'
    config.gcp_scope = 'https://www.googleapis.com/auth/cloud-platform'
  end
end
