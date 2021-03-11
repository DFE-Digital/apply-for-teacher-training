require 'rails_helper'

RSpec.describe DeclineOfferByDefault do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, status: :offer) }

  it 'updates the application_choice and posts Slack notifications' do
    notifier = instance_double(StateChangeNotifier, application_outcome_notification: nil)
    allow(StateChangeNotifier).to receive(:new).and_return(notifier)

    described_class.new(application_form: application_choice.application_form).call

    application_choice.reload

    expect(application_choice.declined_by_default).to eq(true)
    expect(application_choice.declined_at).not_to be_nil

    expect(StateChangeNotifier).to have_received(:new).with(:declined_by_default, application_choice)
    expect(notifier).to have_received(:application_outcome_notification)
  end

  context 'when the configurable provider notifications feature flag is off' do
    before { FeatureFlag.deactivate(:configurable_provider_notifications) }

    it 'sends a notification email to the training provider and ratifying provider', sidekiq: true do
      training_provider = create(:provider)
      training_provider_user = create(:provider_user, send_notifications: true, providers: [training_provider])

      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, send_notifications: true, providers: [ratifying_provider])

      course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
      application_choice = create(:application_choice, :with_offer, course_option: course_option)

      described_class.new(application_form: application_choice.application_form).call

      training_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == training_provider_user.email_address }
      ratifying_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == ratifying_provider_user.email_address }

      expect(training_provider_email['rails-mail-template'].value).to eq('declined_by_default')
      expect(ratifying_provider_email['rails-mail-template'].value).to eq('declined_by_default')
    end
  end

  context 'when the configurable provider notifications feature flag is on' do
    before { FeatureFlag.activate(:configurable_provider_notifications) }

    it 'sends a notification email to the training provider and ratifying provider', sidekiq: true do
      training_provider = create(:provider)
      training_provider_user = create(:provider_user, send_notifications: true, providers: [training_provider])

      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, send_notifications: true, providers: [ratifying_provider])

      course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
      application_choice = create(:application_choice, status: :offer, course_option: course_option)

      described_class.new(application_form: application_choice.application_form).call

      training_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == training_provider_user.email_address }
      ratifying_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == ratifying_provider_user.email_address }

      expect(training_provider_email['rails-mail-template'].value).to eq('declined_by_default')
      expect(ratifying_provider_email['rails-mail-template'].value).to eq('declined_by_default')
    end
  end
end
