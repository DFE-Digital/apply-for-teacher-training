require 'rails_helper'

RSpec.describe Azure::GoogleAccessToken do
  subject(:client) { described_class.new('fake_sts_token') }

  describe 'successful request' do
    before do
      Azure.configure do |c|
        c.google_cloud_credentials = { service_account_impersonation_url: 'https://example.com' }
      end

      stub_request(:post, 'https://example.com')
        .with(
          body: URI.encode_www_form({
            'scope' => 'https://www.googleapis.com/auth/cloud-platform',
          }),
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer fake_sts_token',
            'Content-Type' => 'application/x-www-form-urlencoded',
            'User-Agent' => 'Faraday v1.10.3',
          },

        )
        .to_return(
          status: 200,
          body: {
            expireTime: '2024-03-09T14:38:02Z',
            accessToken: 'fake_google_response_token',
          }.to_json,
          headers: {
            'Content-Type' => ['application/json; charset=utf-8'],
          },
        )
    end

    it 'returns the Google token and expire time' do
      expect(client.call).to eq(['fake_google_response_token', '2024-03-09T14:38:02Z'])
    end
  end

  describe 'Google responds unsuccessful' do
    before do
      Azure.configure do |c|
        c.google_cloud_credentials = { service_account_impersonation_url: 'https://example.com' }
      end

      stub_request(:post, 'https://example.com')
      .to_return(
        status: 401,
        body:
          {
            error: {
              code: 401,
              message: 'Request had invalid authentication credentials. Expected OAuth 2 access token, login cookie or other valid authentication credential. See https://developers.google.com/identity/sign-in/web/devconsole-project.',
              status: 'UNAUTHENTICATED',
              details: [{
                '@type': 'type.googleapis.com/google.rpc.ErrorInfo',
                reason: 'ACCESS_TOKEN_TYPE_UNSUPPORTED',
                metadata: {
                  service: 'iamcredentials.googleapis.com',
                  method: 'google.iam.credentials.v1.IAMCredentials.GenerateAccessToken',
                },
              }],
            },
          }.to_json,
        headers: {
          'content-type' => ['application/json; charset=utf-8'],
        },
      )
    end

    it 'raises a GoogleAPIError' do
      expect { client.call }.to raise_error(Azure::GoogleAPIError).with_message("\r\n\tstatus:\t401\r\n\tbody:\t{\"error\"=>{\"code\"=>401, \"message\"=>\"Request had invalid authentication credentials. Expected OAuth 2 access token, login cookie or other valid authentication credential. See https://developers.google.com/identity/sign-in/web/devconsole-project.\", \"status\"=>\"UNAUTHENTICATED\", \"details\"=>[{\"@type\"=>\"type.googleapis.com/google.rpc.ErrorInfo\", \"reason\"=>\"ACCESS_TOKEN_TYPE_UNSUPPORTED\", \"metadata\"=>{\"service\"=>\"iamcredentials.googleapis.com\", \"method\"=>\"google.iam.credentials.v1.IAMCredentials.GenerateAccessToken\"}}]}}")
    end
  end
end
