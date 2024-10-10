module WorkloadIdentityFederationStubs
  def stub_wif_config(conf = {})
    allow(WorkloadIdentityFederation).to receive(:config) {
      ActiveSupport::OrderedOptions.new.tap do |config|
        config.azure_client_id = 'fake_client_id'
        config.azure_token_file_path = Tempfile.new.path
        config.google_cloud_credentials = {
          credential_source: { url: 'https://example.com' },
          service_account_impersonation_url: 'https://example.com',
          token_url: 'https://sts.googleapis.com/v1/token',
          subject_token_type: 'fake_subject_token_type',
          audience: 'fake_gcp_aud',
        }
        config.azure_scope = 'api://AzureADTokenExchange/.default'
        config.gcp_scope = 'fake_gcp_scope'
      end.deep_merge(conf)
    }
  end

  def stub_azure_access_token
    stub_request(:get, 'https://example.com')
    .to_return(
      status: 200,
      body: {
        'token_type' => 'Bearer',
        'expires_in' => 86_399,
        'ext_expires_in' => 86_399,
        'access_token' => 'fake_az_response_token',
      }.to_json,
      headers: {
        'content-type' => ['application/json; charset=utf-8'],
      },
    )
    allow(File).to receive(:read).and_return('asdf')
  end

  def stub_token_exchange
    stub_request(:post, 'https://sts.googleapis.com/v1/token')
      .with(
        body: {
          'audience' => 'fake_gcp_aud',
          'grant_type' => 'urn:ietf:params:oauth:grant-type:token-exchange',
          'requested_token_type' => 'urn:ietf:params:oauth:token-type:access_token',
          'scope' => 'fake_gcp_scope',
          'subject_token' => 'fake_az_response_token',
          'subject_token_type' => 'fake_subject_token_type',
        },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/x-www-form-urlencoded',
        },
      )
    .to_return(
      status: 200,
      body: {
        token_type: 'Bearer',
        expires_in: 3599,
        issued_token_type: 'urn:ietf:params:oauth:token-type:access_token',
        access_token: 'fake_az_gcp_exchange_token_response',
      }.to_json,
      headers: {
        'content-type' => ['application/json; charset=utf-8'],
      },
    )
  end

  def stub_google_access_token(expire_time: '2024-03-09T14:38:02Z')
    stub_request(:post, 'https://example.com')
      .with(
        body: URI.encode_www_form({
          'scope' => 'fake_gcp_scope',
        }),
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Bearer fake_az_gcp_exchange_token_response',
          'Content-Type' => 'application/x-www-form-urlencoded',
        },

      )
      .to_return(
        status: 200,
        body: {
          expireTime: expire_time,
          accessToken: 'fake_google_response_token',
        }.to_json,
        headers: {
          'Content-Type' => ['application/json; charset=utf-8'],
        },
      )
  end
end
