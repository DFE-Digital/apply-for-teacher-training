require 'rails_helper'

RSpec.describe ProviderInterface::InterviewsController, type: :request do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { build(:course, :open_on_apply, provider: provider) }
  let(:course_option) { build(:course_option, course: course) }
  let(:interview) { create(:interview, application_choice: application_choice) }

  describe 'if application choice is not in a pending decision state' do
    let!(:application_choice) do
      create(:application_choice, :withdrawn,
             application_form: application_form,
             course_option: course_option)
    end

    before do
      allow(DfESignInUser).to receive(:load_from_session).and_return(provider_user)

      FeatureFlag.activate(:interviews)

      user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    end

    context 'GET new' do
      it 'responds with 302' do
        get new_provider_interface_application_choice_interview_path(application_choice)

        expect(response.status).to eq(302)
      end
    end

    context 'GET edit' do
      it 'responds with 302' do
        get edit_provider_interface_application_choice_interview_path(application_choice, interview)

        expect(response.status).to eq(302)
      end
    end

    context 'GET cancel' do
      it 'responds with 302' do
        get cancel_provider_interface_application_choice_interview_path(application_choice, interview)

        expect(response.status).to eq(302)
      end
    end

    context 'POST commit' do
      it 'responds with 302' do
        post confirm_provider_interface_application_choice_interviews_path(application_choice)

        expect(response.status).to eq(302)
      end
    end

    context 'PUT update' do
      it 'responds with 302' do
        put update_provider_interface_application_choice_interview_path(application_choice, interview)

        expect(response.status).to eq(302)
      end
    end

    context 'POST confirm_cancel' do
      it 'responds with 302' do
        post cancel_confirm_provider_interface_application_choice_interview_path(application_choice, interview)

        expect(response.status).to eq(302)
      end
    end
  end
end
