require 'rails_helper'

RSpec.describe SendNewCycleHasStartedEmailToCandidatesWorker, sidekiq: true do
  def setup_candidates
    candidate_1 = create(:candidate)
    candidate_2 = create(:candidate)
    unsubmitted_application_choice = create(:application_choice, :application_not_sent)
    rejected_application_choice = create(:application_choice, :with_rejection)

    create(
      :application_form,
      candidate: candidate_1,
      application_choices: [unsubmitted_application_choice],
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )

    create(
      :application_form,
      candidate: candidate_2,
      application_choices: [rejected_application_choice],
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )

    [candidate_1, candidate_2]
  end

  describe '#perform' do
    context "it is time to send the 'new cycle has started' email" do
      it 'sends emails to candidates who have unsuccessful or unsubmitted applications from the previous cycle' do
        allow(CycleTimetable).to receive(:send_new_cycle_has_started_email?).and_return(true)

        candidate_1, candidate_2 = setup_candidates

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
        setup_candidates

        described_class.new.perform

        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "it is time to send the 'new cycle has started' email but one candidate has already received it" do
      it 'does not send the email' do
        allow(CycleTimetable).to receive(:send_new_cycle_has_started_email?).and_return(true)
        allow(CycleTimetable).to receive(:apply_opens).and_return(1.day.ago)
        candidate_1, candidate_2 = setup_candidates
        candidate_1.current_application.chasers_sent.create(
          chaser_type: :new_cycle_has_started,
        )

        described_class.new.perform

        expect(email_for_candidate(candidate_1)).not_to be_present
        expect(email_for_candidate(candidate_2)).to be_present
      end
    end
  end

  describe 'Staggered email sending' do
    around do |example|
      Timecop.freeze do
        example.run
      end
    end

    before do
      @unsuccessful_candidates = instance_double(ActiveRecord::Relation)
      allow(SendNewCycleHasStartedEmailToCandidatesBatchWorker).to receive(:perform_at).and_return(nil)
    end

    context 'with a single batch' do
      before do
        allow(@unsuccessful_candidates).to receive(:count).and_return(5)
        allow(@unsuccessful_candidates).to receive(:find_in_batches).and_yield(
          (1..5).map { |id| Candidate.new(id: id) },
        )
        allow(GetUnsuccessfulAndUnsubmittedCandidates).to receive(:call).and_return(@unsuccessful_candidates)
        allow(CycleTimetable).to receive(:send_new_cycle_has_started_email?).and_return(true)
      end

      it 'queues one unstaggered SendNewCycleHasStartedEmailToCandidatesBatchWorker job' do
        described_class.new.perform

        expect(SendNewCycleHasStartedEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now, (1..5).to_a),
        )
      end
    end

    context 'with 2 batches' do
      before do
        allow(@unsuccessful_candidates).to receive(:count).and_return(200)
        allow(@unsuccessful_candidates).to receive(:find_in_batches).and_yield(
          (1..120).map { |id| Candidate.new(id: id) },
        ).and_yield(
          (121..200).map { |id| Candidate.new(id: id) },
        )
        allow(GetUnsuccessfulAndUnsubmittedCandidates).to receive(:call).and_return(@unsuccessful_candidates)
        allow(CycleTimetable).to receive(:send_new_cycle_has_started_email?).and_return(true)
      end

      it 'queues two staggered SendNewCycleHasStartedEmailToCandidatesBatchWorker jobs' do
        described_class.new.perform

        expect(SendNewCycleHasStartedEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now, (1..120).to_a),
        )
        expect(SendNewCycleHasStartedEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now + described_class::STAGGER_OVER, (121..200).to_a),
        )
      end
    end

    context 'with 3 batches' do
      before do
        allow(@unsuccessful_candidates).to receive(:count).and_return(300)
        allow(@unsuccessful_candidates).to receive(:find_in_batches).and_yield(
          (1..120).map { |id| Candidate.new(id: id) },
        ).and_yield(
          (121..240).map { |id| Candidate.new(id: id) },
        ).and_yield(
          (241..300).map { |id| Candidate.new(id: id) },
        )
        allow(GetUnsuccessfulAndUnsubmittedCandidates).to receive(:call).and_return(@unsuccessful_candidates)
        allow(CycleTimetable).to receive(:send_new_cycle_has_started_email?).and_return(true)
      end

      it 'queues three staggered SendNewCycleHasStartedEmailToCandidatesBatchWorker jobs' do
        described_class.new.perform

        expect(SendNewCycleHasStartedEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now, (1..120).to_a),
        )
        expect(SendNewCycleHasStartedEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now + (described_class::STAGGER_OVER / 2.0), (121..240).to_a),
        )
        expect(SendNewCycleHasStartedEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now + described_class::STAGGER_OVER, (241..300).to_a),
        )
      end
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
