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

    it 'sends a notification email to the candidate if the application is the last one' do
      allow(CandidateMailers::SendWithdrawnLastApplicationChoiceEmailWorker).to receive(:perform_async).and_return(true)
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, :awaiting_provider_decision, application_form:)

      described_class.new(application_choice:).save!

      expect(CandidateMailers::SendWithdrawnLastApplicationChoiceEmailWorker).to have_received(:perform_async).with(application_form.id)
    end

    it 'does not send a notification email to the candidate if the application is not the last one' do
      allow(CandidateMailers::SendWithdrawnLastApplicationChoiceEmailWorker).to receive(:perform_async).and_return(true)
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, :awaiting_provider_decision, application_form:)
      _other_application_choice = create(:application_choice, :awaiting_provider_decision, application_form:)

      described_class.new(application_choice:).save!

      expect(CandidateMailers::SendWithdrawnLastApplicationChoiceEmailWorker).not_to have_received(:perform_async)
    end
  end

  context 'when accepted_offer is false by default' do
    it 'sends the manual withdrawal notification email to the training provider and ratifying provider', :sidekiq do
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

  context 'when accepted_offer is true' do
    let!(:training_provider) { create(:provider) }
    let!(:training_provider_user) do
      create(:provider_user, :with_notifications_enabled, providers: [training_provider])
    end

    let!(:ratifying_provider) { create(:provider) }
    let!(:ratifying_provider_user) do
      create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])
    end

    let!(:course_option) do
      course_option_for_accredited_provider(
        provider: training_provider,
        accredited_provider: ratifying_provider,
      )
    end

    let!(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, course_option:)
    end

    it 'sends the automatic withdrawal email to the training provider and ratifying provider', :sidekiq do
      described_class.new(application_choice:, accepted_offer: true).save!

      training_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == training_provider_user.email_address }
      ratifying_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == ratifying_provider_user.email_address }

      expect(training_provider_email.rails_mail_template).to eq('application_auto_withdrawn_on_accept_offer')
      expect(ratifying_provider_email.rails_mail_template).to eq('application_auto_withdrawn_on_accept_offer')
    end

    it 'sets the published withdrawal reason to accepted another offer' do
      described_class.new(application_choice:, accepted_offer: true).save!

      application_choice.reload

      expect(application_choice.published_withdrawal_reasons.pluck(:reason)).to contain_exactly(
        'applying-to-another-provider.accepted-another-offer',
      )
    end
  end

  context 'when application form has references with the status feedback requested' do
    let(:cancel_referee_service) { instance_double(CancelReferee) }
    let(:application_form) { create(:completed_application_form) }
    let(:choice) do
      create(:application_choice, :accepted_no_conditions, application_form: application_form)
    end

    before do
      allow(CancelReferee).to receive(:new).and_return(cancel_referee_service)
      allow(cancel_referee_service).to receive(:call)

      application_form.application_references.update!(feedback_status: :feedback_requested)
    end

    context 'when the reason for withdrawing is not "Do not want to train anymore"' do
      it 'does not cancel any requested references' do
        create(
          :withdrawal_reason,
          :draft,
          application_choice: choice,
        )

        described_class.new(application_choice: choice).save!
        expect(cancel_referee_service).not_to have_received(:call)
      end
    end

    context 'when the reason for withdrawing is "Do not want to train anymore"' do
      it 'cancels any requested references' do
        create(
          :withdrawal_reason,
          :draft,
          reason: 'do-not-want-to-train-anymore.another-career-path-or-accepted-a-job-offer',
          application_choice: choice,
          )

        described_class.new(application_choice: choice).save!
        expect(cancel_referee_service).to have_received(:call).twice
      end
    end
  end
end
