require 'rails_helper'

RSpec.describe 'GET /provider/applications' do
  context 'when the user is not associated with a provider' do
    before do
      allow(ProviderUser).to receive(:load_from_session)
        .and_return(
          FactoryBot.build_stubbed(
            :provider_user,
            id: 12345,
            email_address: 'email@example.com',
            dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
          ),
        )

      # do not grant the user permission to view a provider's applications
    end

    it 'returns 403 with the account-creation-in-progress page' do
      get '/provider/applications'

      expect(response).to have_http_status 403
      expect(response.body).to include('Your account is not ready yet')
    end

    it 'reports the error to Sentry, appending the Sign-in UID' do
      allow(Raven).to receive(:user_context)
      allow(Raven).to receive(:capture_exception)

      get '/provider/applications'

      expect(Raven).to have_received(:user_context).with(
        dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
        provider_user_admin_url: 'http://www.example.com/support/users/provider/12345',
      )

      expect(Raven).to have_received(:capture_exception)
    end
  end
end
