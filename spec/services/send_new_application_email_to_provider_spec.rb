require 'rails_helper'

RSpec.describe SendNewApplicationEmailToProvider, sidekiq: true do
  include CourseOptionHelpers

  let(:provider) { create(:provider) }
  let(:provider_user) { create(:provider_user, send_notifications: true, providers: [provider]) }
  let(:course_option) { course_option_for_provider(provider: provider) }

  it 'sends an email to the provider' do
    choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)

    expect {
      SendNewApplicationEmailToProvider.new(application_choice: choice).call
    }.to have_metrics_tracked(choice, 'notifications.on', provider_user, :application_submitted)

    email = ActionMailer::Base.deliveries.find { |e| e.header['rails_mail_template'].value == 'application_submitted' }
    expect(email).to be_present
  end

  it 'sends a different email when the candidate supplied safeguarding information' do
    form = create(:completed_application_form, :with_safeguarding_issues_disclosed)
    choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option, application_form: form)

    expect {
      SendNewApplicationEmailToProvider.new(application_choice: choice).call
    }.to have_metrics_tracked(choice, 'notifications.on', provider_user, :application_submitted_with_safeguarding_issues)

    email = ActionMailer::Base.deliveries.find { |e| e.header['rails_mail_template'].value == 'application_submitted_with_safeguarding_issues' }
    expect(email).to be_present
  end
end
