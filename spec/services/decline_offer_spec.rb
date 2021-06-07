require 'rails_helper'

RSpec.describe DeclineOffer do
  include CourseOptionHelpers

  it 'sets the declined_at date and sends a Slack notification' do
    application_choice = create(:application_choice, status: :offer)
    notifier = instance_double(StateChangeNotifier, application_outcome_notification: nil)
    allow(StateChangeNotifier).to receive(:new).and_return(notifier)

    Timecop.freeze do
      expect {
        described_class.new(application_choice: application_choice).save!
      }.to change { application_choice.declined_at }.to(Time.zone.now)

      expect(StateChangeNotifier).to have_received(:new).with(:declined, application_choice)
      expect(notifier).to have_received(:application_outcome_notification)
    end
  end

  it 'sends a notification email to the training provider and ratifying provider', sidekiq: true do
    training_provider = create(:provider)
    training_provider_user = create(:provider_user, :with_notification_preferences_enabled, providers: [training_provider])

    ratifying_provider = create(:provider)
    ratifying_provider_user = create(:provider_user, :with_notification_preferences_enabled, providers: [ratifying_provider])

    course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
    application_choice = create(:application_choice, status: :offer, course_option: course_option)

    described_class.new(application_choice: application_choice).save!

    training_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == training_provider_user.email_address }
    ratifying_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == ratifying_provider_user.email_address }

    expect(training_provider_email['rails-mail-template'].value).to eq('declined')
    expect(ratifying_provider_email['rails-mail-template'].value).to eq('declined')
  end
end
