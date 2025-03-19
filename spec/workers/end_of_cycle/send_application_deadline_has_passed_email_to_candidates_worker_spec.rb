require 'rails_helper'

RSpec.describe EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesWorker do
  describe '#perform' do
    context 'is before the date for sending the reminder', time: application_deadline_has_passed_email_date - 1.day do
      it 'does not enqueue the batch worker' do
        create(:application_form, :unsubmitted)

        allow(EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'is after the date for sending the reminder', time: application_deadline_has_passed_email_date + 1.day do
      it 'does not enqueue the batch worker' do
        create(:application_form, :unsubmitted)

        allow(EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'is on the date for sending the email', time: application_deadline_has_passed_email_date do
      it 'enqueues the batch worker' do
        unsubmitted_application_form = create(:application_form, :unsubmitted)

        # These two application forms should not be included
        create(:application_form, :submitted)
        create(:application_form, recruitment_cycle_year: RecruitmentCycleTimetable.previous_year)

        # These two won't be sent because these candidates should not receive emails
        blocked_submission_candidate = create(:candidate, submission_blocked: true)
        create(:application_form, :unsubmitted, candidate: blocked_submission_candidate)

        account_locked_candidate = create(:candidate, account_locked: true)
        create(:application_form, :unsubmitted, candidate: account_locked_candidate)

        allow(EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker).to receive(:perform_at)
        described_class.new.perform

        expect(EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker)
          .to have_received(:perform_at).with(kind_of(Time), [unsubmitted_application_form.id])
      end
    end
  end
end
