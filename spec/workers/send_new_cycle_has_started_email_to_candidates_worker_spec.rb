require 'rails_helper'

RSpec.describe SendNewCycleHasStartedEmailToCandidatesWorker do
  def setup_candidates
    unsubmitted_candidate = create(:candidate)
    rejected_candidate = create(:candidate)
    carried_over_candidate = create(:candidate)
    recruited_candidate = create(:candidate)

    create(
      :application_form,
      candidate: unsubmitted_candidate,
      application_choices: [build(:application_choice, :application_not_sent)],
      recruitment_cycle_year: previous_year,
    )

    create(
      :application_form,
      candidate: rejected_candidate,
      application_choices: [build(:application_choice, :rejected)],
      recruitment_cycle_year: previous_year,
    )

    create(
      :application_form,
      candidate: carried_over_candidate,
      application_choices: [build(:application_choice, :application_not_sent)],
      recruitment_cycle_year: previous_year,
    )
    create(
      :application_form,
      candidate: carried_over_candidate,
      recruitment_cycle_year: current_year,
    )

    create(
      :application_form,
      candidate: recruited_candidate,
      recruitment_cycle_year: previous_year,
      application_choices: [build(:application_choice, :recruited)],
    )

    [unsubmitted_candidate, rejected_candidate, carried_over_candidate, recruited_candidate]
  end

  describe '#relation' do
    it 'returns expected candidates' do
      unsubmitted_candidate, rejected_candidate, carried_over_candidate, recruited_candidate = setup_candidates

      relation = described_class.new.relation

      expect(relation).to include(unsubmitted_candidate)
      expect(relation).to include(rejected_candidate)

      expect(relation).not_to include(carried_over_candidate)
      expect(relation).not_to include(recruited_candidate)
    end
  end

  describe '#perform' do
    let(:worker) { instance_double(ActiveJob::ConfiguredJob) }

    before do
      allow(SendNewCycleHasStartedEmailToCandidatesBatchWorker).to receive(:set).and_return(worker)
      allow(worker).to receive(:perform_later).with(Array)
    end

    context "it is time to send the 'new cycle has started' email" do
      it 'enqueues batch worker' do
        travel_temporarily_to(email_send_date) do
          unsubmitted_candidate, rejected_candidate, _carried_over, _recruited = setup_candidates

          candidate_ids = [unsubmitted_candidate.id, rejected_candidate.id]
          described_class.perform_now

          expect(SendNewCycleHasStartedEmailToCandidatesBatchWorker).to have_received(:set)
          expect(worker).to have_received(:perform_later).with(candidate_ids)
        end
      end
    end

    context "it is not time to send the 'new cycle has started' email" do
      it 'does not enqueue batch worker' do
        travel_temporarily_to(email_send_date - 1.day) do
          setup_candidates

          [create(:application_form).candidate.id]
          described_class.perform_now

          expect(SendNewCycleHasStartedEmailToCandidatesBatchWorker).not_to have_received(:set)
        end
      end
    end
  end

  def email_send_date
    EndOfCycle::CandidateEmailTimetabler.email_schedule(:apply_has_opened_announcement_date)
  end
end
