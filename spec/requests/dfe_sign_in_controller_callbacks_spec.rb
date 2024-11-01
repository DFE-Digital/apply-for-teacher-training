require 'rails_helper'

RSpec.describe 'DfESignInController#callbacks' do
  include DfESignInHelpers

  describe 'GET /auth/dfe/callback' do
    let(:omni_auth_hash) do
      fake_dfe_sign_in_auth_hash(
        email_address: 'some@email.address',
        dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
        first_name: '',
        last_name: '',
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:dfe] = omni_auth_hash
    end

    context 'there are no DfE sign omniauth values set' do
      let(:omni_auth_hash) { nil }

      it 'is forbidden by default' do
        get auth_dfe_callback_path

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the Support User does not exist' do
      it 'does not sign in' do
        get support_interface_sign_in_path # makes sure the session[:post_dfe_sign_in_path] is set
        get auth_dfe_callback_path

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when Support User exists with matching dfe_sign_in_uid' do
      let!(:support_user) { create(:support_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

      it 'signs the Support User in' do
        get support_interface_sign_in_path # makes sure the session[:post_dfe_sign_in_path] is set
        get auth_dfe_callback_path

        expect(response).to redirect_to(support_interface_path)
      end

      it 'redirects to the Support interface when the post_dfe_sign_in_path is set to the Provider Interface' do
        # FIXME: Reliance on the session[:post_dfe_sign_in_path] is an anti-pattern
        skip('The use of session[:post_dfe_sign_in_path] is an anti-pattern')

        get provider_interface_sign_in_path # makes sure the session[:post_dfe_sign_in_path] is set
        get auth_dfe_callback_path

        expect(response).to redirect_to(support_interface_path)
      end
    end

    context 'when a different Support User exists with the same email address' do
      let!(:support_user) { create(:support_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }
      let!(:existing_support_user) { create(:support_user, email_address: 'some@email.address') }

      it 'does not sign the Support User in' do
        get support_interface_sign_in_path # makes sure the session[:post_dfe_sign_in_path] is set
        get auth_dfe_callback_path

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when Provider User exists with matching dfe_sign_in_uid' do
      let!(:provider_user) { create(:provider_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

      it 'signs the Provider User in' do
        get provider_interface_sign_in_path # makes sure the session[:post_dfe_sign_in_path] is set
        get auth_dfe_callback_path

        expect(response).to redirect_to(provider_interface_path)
      end

      it 'redirects to the Provider interface when the post_dfe_sign_in_path is set to the Support Interface' do
        # FIXME: Reliance on the session[:post_dfe_sign_in_path] is an anti-pattern
        skip('The use of session[:post_dfe_sign_in_path] is an anti-pattern')

        get support_interface_sign_in_path # makes sure the session[:post_dfe_sign_in_path] is set
        get auth_dfe_callback_path

        expect(response).to redirect_to(provider_interface_path)
      end
    end

    context 'when a different Provider User exists with the same email address' do
      let!(:provider_user) { create(:provider_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }
      let!(:existing_provider_user) { create(:provider_user, email_address: 'some@email.address') }

      it 'does not sign the Provider User in' do
        get provider_interface_sign_in_path # makes sure the session[:post_dfe_sign_in_path] is set
        get auth_dfe_callback_path

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
