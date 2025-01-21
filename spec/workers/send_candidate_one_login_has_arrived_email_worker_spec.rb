require 'rails_helper'

RSpec.describe SendCandidateOneLoginHasArrivedEmailWorker do
  before { allow(OneLogin).to receive(:bypass?).and_return(false) }

  describe '#perform' do
    context 'feature flag is inactivated' do
      before { FeatureFlag.deactivate('one_login_candidate_sign_in') }

      it 'does not enqueue the batch worker' do
        create(:application_form)

        allow(SendOneLoginHasArrivedEmailBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(SendOneLoginHasArrivedEmailBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'feature flag is activated' do
      before { FeatureFlag.activate('one_login_candidate_sign_in') }

      it 'enqueues the batch worker with expected application forms' do
        # Last year's application
        create(:application_form, recruitment_cycle_year: RecruitmentCycle.previous_year)
        # Unsubscribed candidate
        create(:application_form, candidate: build(:candidate, unsubscribed_from_emails: true))
        # Candidate with submission blocked
        create(:application_form, candidate: build(:candidate, submission_blocked: true))
        # Candidate with locked account
        create(:application_form, candidate: build(:candidate, account_locked: true))
        # Candidate has already been sent the email
        create(:email, application_form: build(:application_form), mailer: 'candidate_mailer', mail_template: 'one_login_has_arrived')
        # Candidate who has a one_login_auth record
        with_one_login_auth = create(:candidate, one_login_auth: build(:one_login_auth))
        create(:application_form, candidate: with_one_login_auth)

        should_receive = create(:application_form)

        allow(SendOneLoginHasArrivedEmailBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(SendOneLoginHasArrivedEmailBatchWorker).to have_received(:perform_at).with(kind_of(Time), [should_receive.id])
      end
    end
  end
end
