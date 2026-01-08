require 'rails_helper'

RSpec.describe 'GET /provider' do
  include DfESignInHelpers

  context 'when the user is signed in to Apply' do
    before do
      provider_user = create(:provider_user, :with_dfe_sign_in, :with_provider)
      user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
      get auth_dfe_callback_path
    end

    it 'redirects them to the Provider Interface' do
      get '/provider'

      expect(response).to have_http_status :found
    end
  end

  context 'when the user is not signed in at all' do
    it 'returns 200' do
      get '/provider'

      expect(response).to have_http_status :ok
    end
  end
end
