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

    it 'returns 403 with the email-address-not-recognised page' do
      get '/provider/applications'

      expect(response).to have_http_status :forbidden
      expect(response.body).to include('Your email address is not recognised')
    end
  end
end
