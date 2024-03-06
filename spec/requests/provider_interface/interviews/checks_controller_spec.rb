require 'rails_helper'

RSpec.describe ProviderInterface::Interviews::ChecksController do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions, :with_set_up_interviews) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { build(:course, :open, provider:) }
  let(:course_option) { build(:course_option, course:) }
  let!(:interview) { create(:interview, application_choice:) }

  before do
    allow(DfESignInUser).to receive(:load_from_session).and_return(provider_user)

    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  describe 'when bypass the new check interview page for accredited providers' do
    let(:course) do
      build(
        :course,
        :with_accredited_provider,
        :with_provider_relationship_permissions,
        :open,
        provider:,
      )
    end
    let(:application_choice) do
      create(
        :application_choice,
        :awaiting_provider_decision,
        application_form:,
        course_option:,
      )
    end

    it 'redirects to the new interview page' do
      get new_provider_interface_application_choice_interviews_check_path(application_choice)

      expect(response).to redirect_to(new_provider_interface_application_choice_interview_path(application_choice))
    end
  end

  describe 'going back when the interview store has been cleared' do
    let!(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, application_form:, course_option:)
    end

    let(:store) { instance_double(WizardStateStores::RedisStore, read: nil) }

    before { allow(WizardStateStores::RedisStore).to receive(:new).and_return(store) }

    context 'POST create' do
      it 'redirects to the interviews index' do
        post provider_interface_application_choice_interviews_check_path(application_choice)

        expect(response).to have_http_status(:found)
        expect(response.redirect_url).to eq(provider_interface_application_choice_interviews_url(application_choice))
      end
    end
  end

  describe 'validation errors' do
    let(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, application_form:, course_option:)
    end

    let(:store) { instance_double(WizardStateStores::RedisStore, read: %({ "provider_user" : "#{provider_user.id}" }), write: true) }

    before { allow(WizardStateStores::RedisStore).to receive(:new).and_return(store) }

    it 'tracks validation errors on preview' do
      expect {
        post provider_interface_application_choice_interviews_check_path(application_choice),
             params: { provider_interface_interview_wizard: { location: 'here' } }
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors on update' do
      expect {
        put provider_interface_application_choice_interview_check_path(application_choice, interview),
            params: { provider_interface_interview_wizard: { location: 'here' } }
      }.to change(ValidationError, :count).by(1)
    end
  end
end
