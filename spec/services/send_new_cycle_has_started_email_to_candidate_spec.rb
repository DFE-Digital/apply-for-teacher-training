require 'rails_helper'

RSpec.describe SendNewCycleHasStartedEmailToCandidate do
  describe '#call' do
    let(:application_form) { create(:application_form) }
    let(:candidate_mailer) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    before do
      allow(CandidateMailer).to receive(:new_cycle_has_started).with(application_form).and_return(candidate_mailer)
    end

    context 'where email has already been sent' do
      it 'does not send email' do
        create(:chaser_sent, chased: application_form, chaser_type: :new_cycle_has_started)

        described_class.call(application_form:)

        expect(CandidateMailer).not_to have_received(:new_cycle_has_started)
      end
    end

    context 'where email has not been sent' do
      it 'does send email' do
        described_class.call(application_form:)

        expect(CandidateMailer).to have_received(:new_cycle_has_started).with(application_form)
        expect(candidate_mailer).to have_received(:deliver_later)

        chaser_sent_record = ChaserSent.find_by(chased: application_form, chaser_type: :new_cycle_has_started)
        expect(chaser_sent_record).to be_present
      end
    end
  end
end
