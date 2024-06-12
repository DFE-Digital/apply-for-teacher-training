require 'rails_helper'

RSpec.describe SendNewApplicationEmailToProvider, :sidekiq do
  include CourseOptionHelpers

  it 'sends a notification email to the training provider and ratifying provider', :sidekiq do
    training_provider = create(:provider)
    training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

    ratifying_provider = create(:provider)
    ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

    course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
    application_choice = create(:application_choice, :with_completed_application_form, :awaiting_provider_decision, course_option:)

    described_class.new(application_choice:).call

    training_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == training_provider_user.email_address }
    ratifying_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == ratifying_provider_user.email_address }

    expect(training_provider_email['rails-mail-template'].first.value).to eq('application_submitted')
    expect(ratifying_provider_email['rails-mail-template'].first.value).to eq('application_submitted')
  end

  it 'sends a different email when the candidate supplied safeguarding information' do
    provider = create(:provider)
    create(:provider_user, :with_notifications_enabled, providers: [provider])
    option = course_option_for_provider(provider:)

    form = create(:completed_application_form, :with_safeguarding_issues_disclosed)
    choice = create(:application_choice, :awaiting_provider_decision, course_option: option, application_form: form)

    described_class.new(application_choice: choice).call

    email = ActionMailer::Base.deliveries.find { |e| e.header['rails_mail_template'].first.value == 'application_submitted_with_safeguarding_issues' }

    expect(email).to be_present
  end
end
