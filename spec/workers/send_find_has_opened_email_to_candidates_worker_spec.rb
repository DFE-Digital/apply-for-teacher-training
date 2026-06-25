require 'rails_helper'

RSpec.describe SendFindHasOpenedEmailToCandidatesWorker do
  describe '#perform' do
    let(:worker) { instance_double(ActiveJob::ConfiguredJob) }

    before do
      allow(SendFindHasOpenedEmailToCandidatesBatchWorker).to receive(:set).and_return(worker)
      allow(worker).to receive(:perform_later).with(Array)
    end

    context "it is time to send the 'find has opened' email" do
      it 'enqueues emails to send to candidates' do
        travel_temporarily_to(email_send_date) do
          candidate_ids = [create(:application_form).candidate.id]
          described_class.perform_now

          expect(SendFindHasOpenedEmailToCandidatesBatchWorker).to have_received(:set)
          expect(worker).to have_received(:perform_later).with(candidate_ids)
        end
      end
    end

    context "it is not time to send the 'find has opened' email" do
      it 'does not send the email' do
        travel_temporarily_to(email_send_date - 1.day) do
          create(:application_form)

          described_class.perform_now

          expect(SendFindHasOpenedEmailToCandidatesBatchWorker).not_to have_received(:set)
        end
      end
    end
  end

  def email_send_date
    @email_send_date ||= EndOfCycle::CandidateEmailTimetabler.email_schedule(:find_has_opened_announcement_date).noon
  end
end
