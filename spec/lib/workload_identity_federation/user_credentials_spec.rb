require 'rails_helper'

RSpec.describe WorkloadIdentityFederation::UserCredentials do
  describe 'New token' do
    let(:expire_time) { 10.minutes.from_now.iso8601 }

    before do
      stub_wif_config
      stub_azure_access_token
      stub_token_exchange
      stub_google_access_token(expire_time:)
    end

    after do
      # Instance variable is persisted across tests and must be reset.
      described_class.instance_variable_set(:@gcp_client_credentials, nil)
    end

    it 'returns the Google Credentials' do
      expect(described_class.call).to be_an_instance_of(Google::Auth::UserRefreshCredentials)
    end

    context 'when the token is not expired' do
      it 'makes successful request and generates new token when expired' do
        allow(WorkloadIdentityFederation::AzureAccessToken).to receive(:new).and_call_original
        token = described_class.call
        expect(WorkloadIdentityFederation::AzureAccessToken).to have_received(:new).once

        expect(token).not_to be_expired
        described_class.call

        expect(WorkloadIdentityFederation::AzureAccessToken).to have_received(:new).once

        TestSuiteTimeMachine.advance_time_by(20.minutes)

        expect(token).to be_expired

        described_class.call

        expect(WorkloadIdentityFederation::AzureAccessToken).to have_received(:new).twice
      end
    end
  end
end
