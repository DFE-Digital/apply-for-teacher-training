require 'rails_helper'

RSpec.describe SendNewCycleHasStartedEmailToCandidatesWorker, sidekiq: true do
  describe '#perform' do
    context "it is time to send the 'new cycle has started' email" do
      it 'sends emails to candidates who have unsuccessful or unsubmitted applications from the previous cycle' do
        allow(CycleTimetable).to receive(:send_new_cycle_has_started_email?).and_return(true)

        candidate_1 = create(:candidate)
        candidate_2 = create(:candidate)
        unsubmitted_application_choice = create(:application_choice, :application_not_sent)
        rejected_application_choice = create(:application_choice, :with_rejection)

        create(:application_form,
               candidate: candidate_1,
               application_choices: [unsubmitted_application_choice],
               recruitment_cycle_year: RecruitmentCycle.previous_year)

        create(:application_form,
               candidate: candidate_2,
               application_choices: [rejected_application_choice],
               recruitment_cycle_year: RecruitmentCycle.previous_year)

        described_class.new.perform

        email_for_candidate_1 = email_for_candidate(candidate_1)
        email_for_candidate_2 = email_for_candidate(candidate_2)

        expect(email_for_candidate_1).to be_present
        expect(email_for_candidate_2).to be_present
      end
    end

    context "it is not time to send the 'new cycle has started' email" do
      it 'does not send the email' do
        allow(CycleTimetable).to receive(:send_new_cycle_has_started_email?).and_return(false)

        described_class.new.perform

        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
