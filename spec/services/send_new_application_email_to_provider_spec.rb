require 'rails_helper'

RSpec.describe SendNewApplicationEmailToProvider, sidekiq: true do
  include CourseOptionHelpers

  it 'sends an email to the provider' do
    provider = create(:provider)
    create(:provider_user, send_notifications: true, providers: [provider])
    option = course_option_for_provider(provider: provider)
    choice = create(:application_choice, :awaiting_provider_decision, course_option: option)

    SendNewApplicationEmailToProvider.new(application_choice: choice).call

    email = ActionMailer::Base.deliveries.find { |e| e.header['rails_mail_template'].value == 'application_submitted' }

    expect(email).to be_present
  end

  it 'sends a different email when the candidate supplied safeguarding information' do
    provider = create(:provider)
    create(:provider_user, send_notifications: true, providers: [provider])
    option = course_option_for_provider(provider: provider)

    form = create(:completed_application_form, :with_safeguarding_issues_disclosed)
    choice = create(:application_choice, :awaiting_provider_decision, course_option: option, application_form: form)

    SendNewApplicationEmailToProvider.new(application_choice: choice).call

    email = ActionMailer::Base.deliveries.find { |e| e.header['rails_mail_template'].value == 'application_submitted_with_safeguarding_issues' }

    expect(email).to be_present
  end
end
