require 'rails_helper'

RSpec.describe 'Viewing applications' do
  include DfESignInHelpers

  let!(:provider_user) { create(:provider_user, :with_provider, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }
  let(:provider) { provider_user.providers.first }

  before do
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    get auth_dfe_callback_path
  end

  describe 'GET show with application_choice_id for an application to my provider' do
    it 'responds with 200' do
      application_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: build(:course_option, course: build(:course, provider:)),
      )
      get provider_interface_application_choice_path(application_choice_id: application_choice.id)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET show with invalid application_choice_id param' do
    it 'responds with 404' do
      get provider_interface_application_choice_path(application_choice_id: 666)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET show with application_choice_id param for an application to another provider' do
    it 'responds with 404' do
      application_choice = create(:application_choice)
      get provider_interface_application_choice_path(application_choice_id: application_choice.id)

      expect(response).to have_http_status(:not_found)
    end
  end
end
