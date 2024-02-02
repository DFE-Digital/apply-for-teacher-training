require 'rails_helper'

RSpec.describe 'POST /provider/candidates/:id/impersonate' do
  include CourseOptionHelpers

  context 'when the user is signed in to Apply' do
    let(:provider) { create(:provider) }
    let(:provider_user) { create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }
    let(:course_option) { course_option_for_provider_code(provider_code: provider.code) }
    let(:application_choice) do
      create(:application_choice,
             :with_completed_application_form,
             :awaiting_provider_decision,
             course_option:)
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

    it 'redirects to Candidate Interface if candidate associated with user’s providers', continuous_applications: false do
      post provider_interface_impersonate_candidate_path(application_choice.application_form.candidate)
      expect(response).to have_http_status :found

      get candidate_interface_application_complete_path
      expect(response).to have_http_status :ok # a 200 response suggests a candidate session
    end

    it 'redirects back to Provider Interface if candidate is not associated with user’s providers' do
      unrelated_application = create(:application_choice, status: 'awaiting_provider_decision')

      post provider_interface_impersonate_candidate_path(unrelated_application.application_form.candidate)
      expect(response).to have_http_status :found

      get candidate_interface_continuous_applications_details_path
      expect(response).to have_http_status :found # no candidate session redirects to candidate_interface_path
    end

    it 'returns 404 on production' do
      allow(HostingEnvironment).to receive(:production?).and_return(true)

      post provider_interface_impersonate_candidate_path(application_choice.application_form.candidate)

      expect(response).to have_http_status :not_found
    end
  end
end
