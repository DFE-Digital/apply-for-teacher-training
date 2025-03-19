require 'rails_helper'

RSpec.describe SendNewCycleHasStartedEmailToCandidatesBatchWorker, :sidekiq do
  describe '#perform' do
    def setup_candidates
      candidate_1 = create(:candidate)
      candidate_2 = create(:candidate)
      unsubmitted_application_choice = create(:application_choice, :application_not_sent)
      rejected_application_choice = create(:application_choice, :rejected)

      create(
        :application_form,
        candidate: candidate_1,
        application_choices: [unsubmitted_application_choice],
        recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
      )
      create(
        :application_form,
        candidate: candidate_2,
        application_choices: [rejected_application_choice],
        recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
      )

      [candidate_1, candidate_2]
    end

    it 'sends emails to the given candidates' do
      candidate_1, candidate_2 = setup_candidates

      described_class.new.perform([candidate_1.id, candidate_2.id])

      expect(email_for_candidate(candidate_1)).to be_present
      expect(email_for_candidate(candidate_2)).to be_present
    end

    it 'creates ChaserSent for the given candidates' do
      candidate_1, candidate_2 = setup_candidates

      described_class.new.perform([candidate_1.id, candidate_2.id])

      expect(candidate_1.current_application.chasers_sent.pluck(:chaser_type)).to eq(['new_cycle_has_started'])
      expect(candidate_2.current_application.chasers_sent.pluck(:chaser_type)).to eq(['new_cycle_has_started'])
    end

    it 'does nothing if the email was already sent' do
      allow(CycleTimetable).to receive(:apply_opens).and_return(1.day.ago)
      candidate_1, candidate_2 = setup_candidates

      candidate_1.current_application.chasers_sent.create(
        chaser_type: :new_cycle_has_started,
      )

      described_class.new.perform([candidate_1.id, candidate_2.id])

      expect(email_for_candidate(candidate_1)).not_to be_present
      expect(email_for_candidate(candidate_2)).to be_present
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
