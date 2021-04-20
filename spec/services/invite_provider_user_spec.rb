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
      expect { InviteProviderUser.new }.to raise_error(ArgumentError)
      expect { InviteProviderUser.new(provider_user: ProviderUser.new) }.not_to raise_error
    end

    it 'blows up when DSI_API_URL ENV var is missing' do
      ClimateControl.modify(DSI_API_SECRET: 'something', DSI_API_URL: nil) do
        expect { InviteProviderUser.new(provider_user: ProviderUser.new) }.to raise_error(KeyError, /DSI_API_URL/)
      end
    end

    it 'blows up when DSI_API_SECRET ENV var is missing' do
      ClimateControl.modify(DSI_API_SECRET: nil, DSI_API_URL: 'something') do
        expect { InviteProviderUser.new(provider_user: ProviderUser.new) }.to raise_error(KeyError, /DSI_API_SECRET/)
      end
    end
  end

  describe '#call! if API response is successful' do
    before do
      set_dsi_api_response(success: true)
      InviteProviderUser.new(provider_user: provider_user).call!
    end

    it 'a provider user is created' do
      expect(ProviderUser.find_by_email_address('test+invite_provider_user@example.com')).not_to be_nil
    end

    it 'queues an email' do
      expect(ProviderMailer.deliveries.count).to be 1
    end
  end

  describe '#call! if API response is successful given a ProviderUser#email_address' do
    before do
      allow(SlackNotificationWorker).to receive(:perform_async)
      set_dsi_api_response(success: true)
      InviteProviderUser.new(provider_user: provider_user.email_address).call!
    end

    it 'queues an email' do
      expect(ProviderMailer.deliveries.count).to be 1
    end

    it 'sends a slack message' do
      url = Rails.application.routes.url_helpers.edit_support_interface_provider_user_url(provider_user)

      expect(SlackNotificationWorker).to have_received(:perform_async)
        .with(":technologist: Provider user Firstname has been invited to join #{provider.name}", url)
    end
  end

  describe '#call! if API response is not successful' do
    before do
      allow(SlackNotificationWorker).to receive(:perform_async)
      set_dsi_api_response(success: false)
    end

    it 'raises DfeSignInAPIError with errors from the API' do
      expect { InviteProviderUser.new(provider_user: provider_user).call! }.to raise_error(DfeSignInAPIError)
    end

    it 'does not queue an email' do
      expect(ProviderMailer.deliveries.count).to be 0
    end

    it 'does not notify slack' do
      expect(SlackNotificationWorker).not_to have_received(:perform_async)
    end
  end
end
