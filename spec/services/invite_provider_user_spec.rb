require 'rails_helper'

RSpec.describe InviteProviderUser, sidekiq: true do
  include DsiAPIHelper

  let(:provider) { create(:provider) }
  let(:new_provider_user_from_form) {
    SupportInterface::ProviderUserForm.new(
      email_address: 'test+invite_provider_user@example.com',
      first_name: 'Firstname',
      last_name: 'Lastname',
      provider_ids: [provider.id],
    ).build
  }

  describe '#initialize' do
    it 'requires a provider_user:' do
      expect { InviteProviderUser.new }.to raise_error(ArgumentError)
      expect { InviteProviderUser.new(provider_user: ProviderUser.new) }.not_to raise_error
    end
  end

  describe '#save_and_invite! if API response is successful' do
    before do
      set_dsi_api_response(success: true)
      InviteProviderUser.new(provider_user: new_provider_user_from_form).save_and_invite!
    end

    it 'a provider user is created' do
      expect(ProviderUser.find_by_email_address('test+invite_provider_user@example.com')).not_to be_nil
    end

    it 'queues an email' do
      expect(ProviderMailer.deliveries.count).to be 1
    end
  end

  describe '#save_and_invite! if API response is not successful' do
    before do
      set_dsi_api_response(success: false)
    end

    it 'raises DfeSignInApiError with errors from the API' do
      expect { InviteProviderUser.new(provider_user: new_provider_user_from_form).save_and_invite! }.to raise_error(DfeSignInApiError)
    end

    it 'rolls back provider user creation' do
      InviteProviderUser.new(provider_user: new_provider_user_from_form).save_and_invite! rescue nil
      expect(ProviderUser.find_by_email_address('test+invite_provider_user@example.com')).to be_nil
    end

    it 'does not queue an email' do
      expect(ProviderMailer.deliveries.count).to be 0
    end
  end
end
