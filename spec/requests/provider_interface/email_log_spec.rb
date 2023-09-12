require 'rails_helper'

RSpec.describe 'GET /application_choices/:id/emails' do
  include CourseOptionHelpers

  let(:provider) { create(:provider) }
  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           course_option: course_option_for_provider(provider:))
  end

  before do
    provider_user = create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')

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

  it 'responds with 403 if sandbox mode is disabled', sandbox: false do
    get provider_interface_application_choice_emails_path(application_choice)

    expect(response).to have_http_status(:forbidden)
  end

  it 'responds with 200 if sandbox mode is enabled', :sandbox do
    get provider_interface_application_choice_emails_path(application_choice)

    expect(response).to have_http_status(:ok)
  end
end
