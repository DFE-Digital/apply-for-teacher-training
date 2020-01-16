require 'rails_helper'

RSpec.describe InviteProviderUser do
  include DsiAPIHelper

  let(:provider) { create(:provider) }
  let(:new_provider_user_form) {
    SupportInterface::ProviderUserForm.new(
      email_address: 'test+invite_provider_user@example.com',
      first_name: 'Firstname',
      last_name: 'Lastname',
      provider_ids: [provider.id],
    )
  }

  describe '#initialize' do
    it 'requires a provider_user_form:' do
      expect { InviteProviderUser.new }.to raise_error(ArgumentError)
      expect { InviteProviderUser.new(provider_user_form: SupportInterface::ProviderUserForm.new) }.not_to raise_error
    end
  end

  context 'with feature flag on' do
    describe '#call if API response is successful' do
      before do
        FeatureFlag.activate('send_dfe_sign_in_invitations')
        set_dsi_api_response(success: true)
        InviteProviderUser.new(provider_user_form: new_provider_user_form).call
      end

      it 'a provider user is created' do
        expect(ProviderUser.find_by_email_address('test+invite_provider_user@example.com')).not_to be_nil
      end
    end

    describe '#call if API response is not successful' do
      before do
        FeatureFlag.activate('send_dfe_sign_in_invitations')
        set_dsi_api_response(success: false)
        InviteProviderUser.new(provider_user_form: new_provider_user_form).call
      end

      it 'adds ProviderUserForm errors based on the API response' do
        expect(new_provider_user_form.errors).not_to be_empty
      end

      it 'rolls back provider user creation' do
        expect(ProviderUser.find_by_email_address('test+invite_provider_user@example.com')).to be_nil
      end
    end
  end

  context 'with feature flag off' do
    let(:http_spy) { class_spy('HTTP') }

    before do
      FeatureFlag.deactivate('send_dfe_sign_in_invitations')
      allow(HTTP).to receive(:auth).and_return http_spy

      InviteProviderUser.new(provider_user_form: new_provider_user_form).call
    end

    it '#call no DfE Sign-In invitations are triggered' do
      expect(http_spy).not_to have_received(:post)
    end

    it '#call a provider user is created' do
      expect(ProviderUser.find_by_email_address('test+invite_provider_user@example.com')).not_to be_nil
    end
  end
end
