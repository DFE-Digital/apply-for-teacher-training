require 'rails_helper'

RSpec.describe 'GET /support/applications' do
  context 'when the DfE Sign-in account is not authorized' do
    before do
      allow(SupportUser).to receive(:load_from_session)
        .and_return(
          SupportUser.new(
            email_address: 'email@example.com',
            dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
          ),
      )

      # do not grant the user permission to view a provider's applications
    end

    it 'returns 403 with the account-creation-in-progress page' do
      get '/support/applications'

      expect(response).to have_http_status 403
      expect(response.body).to include('Your account is not authorized')
    end
  end
end
