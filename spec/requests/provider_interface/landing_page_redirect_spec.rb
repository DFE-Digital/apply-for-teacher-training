require 'rails_helper'

RSpec.describe 'GET /provider' do
  context 'when the user is logged in to Apply' do
    before do
      allow(ProviderUser).to receive(:load_from_session)
        .and_return(
          ProviderUser.new(
            email_address: 'email@example.com',
            dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
          ),
      )
    end

    it 'redirects them to the Provider Interface' do
      get '/provider'

      expect(response).to have_http_status 302
    end
  end

  context 'when the user is not logged in at all' do
    it 'returns 200' do
      get '/provider'

      expect(response).to have_http_status 200
    end
  end
end
