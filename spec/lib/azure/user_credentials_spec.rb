require 'rails_helper'

RSpec.describe Azure::UserCredentials do
  let(:expire_time) { '2024-03-09T14:38:02Z' }

  describe 'New token' do
    before do
      stub_azure_config
      stub_azure_access_token
      stub_token_exchange
      stub_google_access_token(expire_time:)
    end

    it 'returns the Google token and expire time' do
      expect(described_class.call).to be_an_instance_of(Google::Auth::UserRefreshCredentials)
    end

    context 'when the token is not expired' do
      let(:expire_time) { 10.minutes.from_now.iso8601 }

      it 'returns the cached token' do
        allow(Azure::AccessToken).to receive(:new).and_call_original
        token = described_class.call
        expect(Azure::AccessToken).to have_received(:new).once

        expect(token).not_to be_expired
        described_class.call

        expect(Azure::AccessToken).to have_received(:new).once

        TestSuiteTimeMachine.advance_time_by(20.minutes)

        expect(token).to be_expired

        described_class.call

        expect(Azure::AccessToken).to have_received(:new).twice
      end
    end
  end
end
