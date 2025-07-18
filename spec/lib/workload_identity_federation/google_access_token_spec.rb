require 'rails_helper'

RSpec.describe WorkloadIdentityFederation::GoogleAccessToken do
  subject(:client) { described_class.new('fake_az_gcp_exchange_token_response') }

  describe 'successful request' do
    before do
      stub_wif_config
      stub_google_access_token
    end

    it 'returns the Google token and expire time' do
      expect(client.call).to eq(['fake_google_response_token', '2024-03-09T14:38:02Z'])
    end
  end

  describe 'Google responds unsuccessful' do
    before do
      stub_wif_config

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
      expect { client.call }.to raise_error(WorkloadIdentityFederation::GoogleAPIError).with_message("\r\n\tstatus:\t401\r\n\tbody:\t{\"error\" => {\"code\" => 401, \"message\" => \"Request had invalid authentication credentials. Expected OAuth 2 access token, login cookie or other valid authentication credential. See https://developers.google.com/identity/sign-in/web/devconsole-project.\", \"status\" => \"UNAUTHENTICATED\", \"details\" => [{\"@type\" => \"type.googleapis.com/google.rpc.ErrorInfo\", \"reason\" => \"ACCESS_TOKEN_TYPE_UNSUPPORTED\", \"metadata\" => {\"service\" => \"iamcredentials.googleapis.com\", \"method\" => \"google.iam.credentials.v1.IAMCredentials.GenerateAccessToken\"}}]}}")
    end
  end
end
