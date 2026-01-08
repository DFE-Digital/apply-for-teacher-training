require 'rails_helper'

RSpec.describe ProviderInterface::ContentController do
  include DfESignInHelpers

  before do
    provider_user = create(:provider_user, :with_dfe_sign_in, :with_provider)
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    get auth_dfe_callback_path
  end

  describe 'visit /provider/service-guidance' do
    it 'returns 200' do
      get provider_interface_service_guidance_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'visit /provider/service-guidance/dates-and-deadlines' do
    it 'returns 200' do
      get provider_interface_service_guidance_dates_and_deadlines_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'visit /provider/privacy' do
    it 'returns 200' do
      get provider_interface_privacy_path

      expect(response).to have_http_status :ok
    end
  end
end
