require 'rails_helper'

RSpec.describe 'DfESignInController#callbacks' do
  include DfESignInHelpers

  before do
    OmniAuth.config.test_mode = true
  end

  describe 'GET /auth/dfe/callback' do
    it 'is forbidden by default' do
      get auth_dfe_callback_path

      expect(response).to have_http_status(:forbidden)
    end
  end
end
