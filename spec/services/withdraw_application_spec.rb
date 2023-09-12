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

    it 'calls SetDeclineByDefault with the withdrawn application’s application_form' do
      decline_by_default = instance_double(SetDeclineByDefault, call: nil)
      withdrawing_application = create(:application_choice, status: :awaiting_provider_decision)
      allow(SetDeclineByDefault).to receive(:new).and_return(decline_by_default)

      described_class.new(application_choice: withdrawing_application).save!

      expect(SetDeclineByDefault).to have_received(:new).with(application_form: withdrawing_application.application_form)
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

    context 'CancelOutstandingReferences service' do
      let(:withdrawing_application) { create(:application_choice, status: :awaiting_provider_decision) }
      let(:cancel_service) { instance_double(CancelOutstandingReferences, call!: true) }
      let(:application_form) { withdrawing_application.application_form }

      before do
        allow(CancelOutstandingReferences)
        .to receive(:new)
        .with(application_form: withdrawing_application.application_form)
        .and_return(cancel_service)
      end

      it 'is called when all applications have ended without success' do
        unsuccessful_application_choices = [create(:application_choice, :rejected), create(:application_choice, :rejected), withdrawing_application]
        application_form.application_choices << unsuccessful_application_choices

        described_class.new(application_choice: withdrawing_application).save!

        expect(cancel_service).to have_received(:call!)
      end

      it 'is not called when there are applications that have not ended without success' do
        application_choices_accepted = [create(:application_choice, status: 'pending_conditions'), create(:application_choice, status: 'withdrawn'), withdrawing_application]
        application_form.application_choices << application_choices_accepted

        described_class.new(application_choice: withdrawing_application).save!

        expect(cancel_service).not_to have_received(:call!)
      end
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

      expect(training_provider_email['rails-mail-template'].value).to eq('application_withdrawn')
      expect(ratifying_provider_email['rails-mail-template'].value).to eq('application_withdrawn')
    end
  end
end
