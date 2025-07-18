require 'rails_helper'

RSpec.describe WorkloadIdentityFederation::GoogleTokenExchange do
  subject(:client) { described_class.new('abc') }

  let(:token_url) { 'https://sts.googleapis.com/v1/token' }

  describe 'successful request' do
    before do
      stub_wif_config

      stub_request(:post, token_url)
        .with(
          body: { 'audience' => 'fake_gcp_aud', 'grant_type' => 'urn:ietf:params:oauth:grant-type:token-exchange', 'requested_token_type' => 'urn:ietf:params:oauth:token-type:access_token', 'scope' => 'fake_gcp_scope', 'subject_token' => 'abc', 'subject_token_type' => 'fake_subject_token_type' },
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

    it 'returns the GCP token' do
      expect(client.call).to eq('fake_az_gcp_exchange_token_response')
    end
  end

  describe 'STS responds unsuccessful' do
    before do
      stub_wif_config

      stub_request(:post, token_url)
      .to_return(
        status: 400,
        body: {
          error: 'invalid_grant',
          error_description: 'Unable to parse the ID Token.',
        }.to_json,
        headers: {
          'content-type' => ['application/json; charset=utf-8'],
        },
      )
    end

    it 'raises an STSAPIError' do
      expect { client.call }.to raise_error(WorkloadIdentityFederation::STSAPIError).with_message("\r\n\tstatus:\t400\r\n\tbody:\t{\"error\" => \"invalid_grant\", \"error_description\" => \"Unable to parse the ID Token.\"}")
    end
  end
end
