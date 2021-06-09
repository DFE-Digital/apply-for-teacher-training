require 'rails_helper'

RSpec.describe SendRejectByDefaultEmailToProvider do
  include CourseOptionHelpers

  it 'returns false if the application is not in rejected state' do
    application_choice = build(:application_choice, :awaiting_provider_decision)

    expect(described_class.new(application_choice: application_choice).call).to eq(false)
  end

  it 'sends a notification email to the training provider', sidekiq: true do
    training_provider = create(:provider)
    training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

    application_choice = create(:application_choice, :with_rejection_by_default, application_form: create(:application_form, :minimum_info), course_option: course_option_for_provider(provider: training_provider))

    described_class.new(application_choice: application_choice).call

    training_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == training_provider_user.email_address }

    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(training_provider_email['rails-mail-template'].value).to eq('application_rejected_by_default')
  end
end
