require 'rails_helper'

RSpec.describe ProviderInterface::Interviews::CancelController do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions, :with_set_up_interviews) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { build(:course, :open, provider:) }
  let(:course_option) { build(:course_option, course:) }
  let(:interview) { create(:interview, application_choice:) }

  before do
    allow(DfESignInUser).to receive(:load_from_session).and_return(provider_user)

    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  describe 'if application choice is not in a pending decision state' do
    let!(:application_choice) do
      create(:application_choice, :withdrawn,
             application_form:,
             course_option:)
    end

    context 'GET cancel' do
      it 'responds with 302' do
        get new_provider_interface_application_choice_interview_cancel_path(application_choice, interview)

        expect(response).to have_http_status(:found)
      end
    end

    context 'DESTROY delete' do
      it 'responds with 302' do
        delete provider_interface_application_choice_interview_path(application_choice, interview)

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'if interview date_and_time has passed' do
    let(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, application_form:, course_option:)
    end
    let!(:interview) { create(:interview, :past_date_and_time, application_choice:) }

    context 'GET cancel' do
      it 'responds with 302' do
        get new_provider_interface_application_choice_interview_cancel_path(application_choice, interview)

        expect(response).to have_http_status(:found)
      end
    end

    context 'POST cancel' do
      it 'responds with 302' do
        post provider_interface_application_choice_interview_cancel_path(application_choice, interview)

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'validation errors' do
    let(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, application_form:, course_option:)
    end

    let(:store) { instance_double(WizardStateStores::RedisStore, read: %({ }), write: true) }

    before { allow(WizardStateStores::RedisStore).to receive(:new).and_return(store) }

    it 'tracks validation errors on create' do
      expect {
        post provider_interface_application_choice_interview_cancel_path(application_choice, interview),
             params: { provider_interface_cancel_interview_wizard: { cancellation_reason: nil } }
      }.to change(ValidationError, :count).by(1)
    end
  end
end
