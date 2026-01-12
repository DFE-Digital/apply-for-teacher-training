require 'rails_helper'

RSpec.describe ProviderInterface::RejectionsController do
  include DfESignInHelpers
  include ModelWithErrorsStubHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:course_option) { build(:course_option, course: build(:course, :open, provider:)) }
  let(:application_choice) do
    create(:application_choice,
           status:,
           application_form: build(:application_form, :minimum_info),
           course_option:)
  end

  before do
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    get auth_dfe_callback_path
  end

  describe 'GET edit' do
    context 'if application choice is in a rejectable state' do
      let(:status) { 'awaiting_provider_decision' }

      it 'responds with 200' do
        get new_provider_interface_rejection_path(application_choice)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'if application_choice is not rejectable' do
      let(:status) { 'rejected' }

      it 'responds with 404' do
        get new_provider_interface_rejection_path(application_choice)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
