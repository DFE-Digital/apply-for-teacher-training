require 'rails_helper'

RSpec.describe SendRejectByDefaultEmailToProvider, sidekiq: true do
  include CourseOptionHelpers

  let(:provider) { create(:provider) }
  let(:option) { course_option_for_provider(provider: provider) }
  let(:application_choice) { create(:application_choice, :with_rejection, course_option: option) }

  describe 'when a provider_user has notifications on' do
    let(:provider_user) { create(:provider_user, send_notifications: true, providers: [provider]) }

    it 'sends an email to the provider users and tracks a notification on metric' do
      expect {
        SendRejectByDefaultEmailToProvider.new(application_choice: application_choice).call
      }.to have_metrics_tracked(application_choice, 'notifications.on', provider_user, :application_rejected_by_default)

      email = ActionMailer::Base.deliveries.find { |e| e.header['rails_mail_template'].value == 'application_rejected_by_default' }
      expect(email).to be_present
    end
  end

  describe 'when a provider_user has notifications off' do
    let(:provider_user) { create(:provider_user, send_notifications: false, providers: [provider]) }

    it 'tracks a notification off metric' do
      expect {
        SendRejectByDefaultEmailToProvider.new(application_choice: application_choice).call
      }.to have_metrics_tracked(application_choice, 'notifications.off', provider_user, :application_rejected_by_default)
    end
  end
end
