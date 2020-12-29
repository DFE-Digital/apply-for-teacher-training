require 'rails_helper'

RSpec.describe SendRejectByDefaultEmailToProvider, sidekiq: true do
  include CourseOptionHelpers

  it 'sends an email to the provider users' do
    provider = create(:provider)
    provider_user = create(:provider_user, send_notifications: true, providers: [provider])
    option = course_option_for_provider(provider: provider)
    application_choice = create(:application_choice, :with_rejection, course_option: option)

    expect {
      SendRejectByDefaultEmailToProvider.new(application_choice: application_choice).call
    }.to have_metrics_tracked(application_choice, 'notifications.on', provider_user, :application_rejected_by_default)

    email = ActionMailer::Base.deliveries.find { |e| e.header['rails_mail_template'].value == 'application_rejected_by_default' }
    expect(email).to be_present
  end
end
