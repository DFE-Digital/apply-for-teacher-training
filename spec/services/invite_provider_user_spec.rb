require 'rails_helper'

RSpec.describe InviteProviderUser, sidekiq: true do
  include DsiAPIHelper

  let(:provider) { create(:provider) }
  let(:provider_user) do
    create(
      :provider_user,
      email_address: 'test+invite_provider_user@example.com',
      first_name: 'Firstname',
      last_name: 'Lastname',
      providers: [provider],
    )
  end

  describe '#initialize' do
    it 'requires a provider_user:' do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new(provider_user: ProviderUser.new) }.not_to raise_error
    end

    it 'blows up when DSI_API_URL ENV var is missing' do
      ClimateControl.modify(DSI_API_SECRET: 'something', DSI_API_URL: nil) do
        expect { described_class.new(provider_user: ProviderUser.new) }.to raise_error(KeyError, /DSI_API_URL/)
      end
    end

    it 'blows up when DSI_API_SECRET ENV var is missing' do
      ClimateControl.modify(DSI_API_SECRET: nil, DSI_API_URL: 'something') do
        expect { described_class.new(provider_user: ProviderUser.new) }.to raise_error(KeyError, /DSI_API_SECRET/)
      end
    end
  end

  describe '#call! if API response is successful' do
    before do
      dsi_api_response(success: true)
      described_class.new(provider_user: provider_user).call!
    end

    it 'a provider user is created' do
      expect(ProviderUser.find_by_email_address('test+invite_provider_user@example.com')).not_to be_nil
    end
  end

  describe '#call! if API response is not successful' do
    before do
      allow(SlackNotificationWorker).to receive(:perform_async)
      dsi_api_response(success: false)
    end

    it 'raises DfeSignInAPIError with errors from the API' do
      expect { described_class.new(provider_user: provider_user).call! }.to raise_error(DfeSignInAPIError)
    end

    it 'does not queue an email' do
      expect(ProviderMailer.deliveries.count).to be 0
    end

    it 'does not notify slack' do
      expect(SlackNotificationWorker).not_to have_received(:perform_async)
    end
  end

  describe '#notify' do
    before do
      described_class.new(provider_user: provider_user).notify
    end

    it 'queues an email' do
      expect(ProviderMailer.deliveries.count).to be 1
    end

    it 'sends a slack message' do
      expect_slack_message_with_text(":technologist: Provider user Firstname has been invited to join #{provider.name}")
    end
  end
end
