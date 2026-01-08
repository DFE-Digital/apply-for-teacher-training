require 'rails_helper'

RSpec.describe 'GET /provider/applications' do
  include DfESignInHelpers

  context 'when the user is not associated with a provider' do
    before do
      provider_user = create(
        :provider_user,
        id: 12345,
        email_address: 'email@example.com',
        dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      )
      user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
      get auth_dfe_callback_path
    end

    it 'returns 403 with the email-address-not-recognised page' do
      get '/provider/applications'

      expect(response).to have_http_status :forbidden
      expect(response.body).to include('Your email address is not recognised')
    end
  end
end
