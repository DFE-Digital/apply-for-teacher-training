require 'rails_helper'

RSpec.describe 'GET /application_choices/:id/emails' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:provider) { create(:provider) }
  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           course_option: course_option_for_provider(provider:))
  end

  before do
    provider_user = create(:provider_user, :with_dfe_sign_in, providers: [provider])
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    get auth_dfe_callback_path
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
