require 'rails_helper'

RSpec.describe WithdrawApplication do
  include CourseOptionHelpers

  describe '#save!' do
    it 'changes the state of the application_choice to "withdrawn"' do
      choice = create(:application_choice, status: :awaiting_provider_decision)

      described_class.new(application_choice: choice).save!

      choice.reload
      expect(choice.status).to eq 'withdrawn'
      expect(choice.withdrawn_or_declined_for_candidate_by_provider).to be false
    end

    it 'cancels upcoming interviews for the withdrawn application' do
      cancel_service = instance_double(CancelUpcomingInterviews, call!: true)
      withdrawing_application = create(:application_choice, status: :interviewing)
      allow(CancelUpcomingInterviews).to receive(:new)
                                           .with(
                                             actor: withdrawing_application.candidate,
                                             application_choice: withdrawing_application,
                                             cancellation_reason: 'You withdrew your application.',
                                           )
                                           .and_return(cancel_service)

      described_class.new(application_choice: withdrawing_application).save!

      expect(cancel_service).to have_received(:call!)
    end

    it 'sends a notification email to the training provider and ratifying provider', :sidekiq do
      training_provider = create(:provider)
      training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

      course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
      application_choice = create(:application_choice, :awaiting_provider_decision, course_option:)

      described_class.new(application_choice:).save!

      training_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == training_provider_user.email_address }
      ratifying_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == ratifying_provider_user.email_address }

      expect(training_provider_email.rails_mail_template).to eq('application_withdrawn')
      expect(ratifying_provider_email.rails_mail_template).to eq('application_withdrawn')
    end
  end
end
