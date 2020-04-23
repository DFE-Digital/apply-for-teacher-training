require 'rails_helper'

RSpec.describe InviteProviderUser, sidekiq: true do
  include DsiAPIHelper

  let(:provider) { create(:provider) }
  let(:provider_user) {
    create(
      :provider_user,
      email_address: 'test+invite_provider_user@example.com',
      first_name: 'Firstname',
      last_name: 'Lastname',
      providers: [provider],
    )
  }

  describe '#initialize' do
    it 'requires a provider_user:' do
      expect { InviteProviderUser.new }.to raise_error(ArgumentError)
      expect { InviteProviderUser.new(provider_user: ProviderUser.new) }.not_to raise_error
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

  describe '#call! if API response is not successful' do
    before do
      set_dsi_api_response(success: false)
    end

    it 'raises DfeSignInAPIError with errors from the API' do
      expect { InviteProviderUser.new(provider_user: provider_user).call! }.to raise_error(DfeSignInAPIError)
    end

    it 'does not queue an email' do
      expect(ProviderMailer.deliveries.count).to be 0
    end
  end
end
