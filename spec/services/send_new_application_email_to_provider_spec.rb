require 'rails_helper'

RSpec.describe SendNewApplicationEmailToProvider, sidekiq: true do
  include CourseOptionHelpers

  let(:provider) { create(:provider) }
  let(:course_option) { course_option_for_provider(provider: provider) }

  describe '.application_submitted' do
    let!(:choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option) }

    describe 'when provider_user notifications are on' do
      let!(:provider_user) { create(:provider_user, send_notifications: true, providers: [provider]) }

      it 'sends an email to the provider' do
        expect {
          described_class.new(application_choice: choice).call
        }.to have_metrics_tracked(choice, 'notifications.on', provider_user, :application_submitted)

        email = ActionMailer::Base.deliveries.find { |e| e.header['rails_mail_template'].value == 'application_submitted' }
        expect(email).to be_present
      end
    end

    describe 'when provider_user notifications are off' do
      let!(:provider_user) { create(:provider_user, send_notifications: false, providers: [provider]) }

      it 'tracks that a notification was sent' do
        expect {
          described_class.new(application_choice: choice).call
        }.to have_metrics_tracked(choice, 'notifications.off', provider_user, :application_submitted)
      end
    end
  end

  describe '.application_submitted_with_safeguarding_issues' do
    let(:form) { create(:completed_application_form, :with_safeguarding_issues_disclosed) }
    let!(:choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option, application_form: form) }

    describe 'when provider_user notifications are on' do
      let!(:provider_user) { create(:provider_user, send_notifications: true, providers: [provider]) }

      it 'sends an email to the provider' do
        expect {
          described_class.new(application_choice: choice).call
        }.to have_metrics_tracked(choice, 'notifications.on', provider_user, :application_submitted_with_safeguarding_issues)

        email = ActionMailer::Base.deliveries.find { |e| e.header['rails_mail_template'].value == 'application_submitted_with_safeguarding_issues' }
        expect(email).to be_present
      end

      describe 'when provider_user notifications are off' do
        let!(:provider_user) { create(:provider_user, send_notifications: false, providers: [provider]) }

        it 'tracks that a notification was sent' do
          expect {
            described_class.new(application_choice: choice).call
          }.to have_metrics_tracked(choice, 'notifications.off', provider_user, :application_submitted_with_safeguarding_issues)
        end
      end
    end
  end
end
