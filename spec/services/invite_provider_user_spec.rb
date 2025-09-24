require 'rails_helper'

RSpec.describe InviteProviderUser, :sidekiq do
  include DsiAPIHelper

  let(:provider) { create(:provider) }
  let(:email) { 'test+invite_provider_user@example.com' }
  let(:provider_user) do
    create(
      :provider_user,
      email_address: email,
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
      described_class.new(provider_user:).call!
    end

    it 'a provider user is created' do
      expect(ProviderUser.find_by(email_address: 'test+invite_provider_user@example.com')).not_to be_nil
    end
  end

  describe '#call! if a string is passed as the provider user param' do
    let(:service) { described_class.new(provider_user: email) }
    let(:email) { 'Test.Email@Email.Com' }

    before do
      dsi_api_response(success: true)
    end

    context 'when a provider user exists with the email address' do
      let!(:provider_user) do
        create(
          :provider_user,
          email_address: email.downcase,
          first_name: 'Firstname',
          last_name: 'Lastname',
          providers: [provider],
        )
      end

      it 'does not throw an error' do
        expect { service.call! }.not_to raise_error
      end
    end

    context 'when no provider user has a matching email address' do
      it 'throws an error' do
        expect { service.call! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#call! if API response is not successful' do
    before do
      dsi_api_response(success: false)
    end

    it 'raises DfeSignInAPIError with errors from the API' do
      expect { described_class.new(provider_user:).call! }.to raise_error(DfeSignInAPIError)
    end

    it 'does not queue an email' do
      expect(ProviderMailer.deliveries.count).to be 0
    end
  end
end
