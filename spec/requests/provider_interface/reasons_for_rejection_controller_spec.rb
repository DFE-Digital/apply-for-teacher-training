require 'rails_helper'

RSpec.describe ProviderInterface::ReasonsForRejectionController, type: :request do
  include DfESignInHelpers
  include ModelWithErrorsStubHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:course_option) { build(:course_option, course: build(:course, :open_on_apply, provider: provider)) }
  let(:application_choice) do
    create(:application_choice,
           status: status,
           application_form: build(:application_form, :minimum_info),
           course_option: course_option)
  end

  before do
    allow(DfESignInUser).to receive(:load_from_session)
      .and_return(
        DfESignInUser.new(
          email_address: provider_user.email_address,
          dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
          first_name: provider_user.first_name,
          last_name: provider_user.last_name,
        ),
      )
  end

  describe 'if application choice is in a rejectable state' do
    let(:status) { 'awaiting_provider_decision' }

    it 'responds with 200' do
      get provider_interface_reasons_for_rejection_initial_questions_path(application_choice)

      expect(response.status).to eq(200)
    end
  end

  describe 'if application choice is not in a rejectable state' do
    let(:status) { (ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER - ApplicationStateChange::DECISION_PENDING_STATUSES).sample }

    context 'GET initial_questions' do
      it 'responds with 404' do
        get provider_interface_reasons_for_rejection_initial_questions_path(application_choice)

        expect(response.status).to eq(404)
      end
    end

    context 'POST update_initial_questions' do
      it 'responds with 404' do
        post provider_interface_reasons_for_rejection_update_initial_questions_path(application_choice)

        expect(response.status).to eq(404)
      end
    end

    context 'GET other_reasons' do
      it 'responds with 404' do
        get provider_interface_reasons_for_rejection_other_reasons_path(application_choice)

        expect(response.status).to eq(404)
      end
    end

    context 'POST update_other_reasons' do
      it 'responds with 404' do
        post provider_interface_reasons_for_rejection_update_other_reasons_path(application_choice)

        expect(response.status).to eq(404)
      end
    end

    context 'GET check' do
      it 'responds with 404' do
        get provider_interface_reasons_for_rejection_check_path(application_choice)

        expect(response.status).to eq(404)
      end
    end

    context 'POST commit' do
      it 'responds with 404' do
        post provider_interface_reasons_for_rejection_commit_path(application_choice)

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'validation errors' do
    let(:status) { 'awaiting_provider_decision' }

    before do
      stub_model_instance_with_errors(
        ProviderInterface::ReasonsForRejectionWizard,
        valid_for_current_step?: false, reason_not_captured_by_initial_questions?: true, to_model: ReasonsForRejection.new({}),
      )
    end

    it 'tracks validation errors on update_initial_questions' do
      expect {
        post provider_interface_reasons_for_rejection_update_initial_questions_path(application_choice),
             params: { reasons_for_rejection: { candidate_behaviour_y_n: '' } }
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors on update_other_reasons' do
      expect {
        post provider_interface_reasons_for_rejection_update_other_reasons_path(application_choice),
             params: { reasons_for_rejection: { candidate_behaviour_y_n: '' } }
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors on commit' do
      stub_model_instance_with_errors(RejectApplication, { save: false })

      expect {
        post provider_interface_reasons_for_rejection_commit_path(application_choice)
      }.to change(ValidationError, :count).by(1)
    end
  end
end
