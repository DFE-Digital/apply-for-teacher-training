require 'rails_helper'

RSpec.describe SendNewCycleHasStartedEmailToCandidatesWorker, :sidekiq do
  def setup_candidates
    unsubmitted_candidate = create(:candidate)
    rejected_candidate = create(:candidate)
    carried_over_candidate = create(:candidate)
    recruited_candidate = create(:candidate)

    create(
      :application_form,
      candidate: unsubmitted_candidate,
      application_choices: [build(:application_choice, :application_not_sent)],
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )

    create(
      :application_form,
      candidate: rejected_candidate,
      application_choices: [build(:application_choice, :rejected)],
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )

    create(
      :application_form,
      candidate: carried_over_candidate,
      application_choices: [build(:application_choice, :application_not_sent)],
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )
    create(
      :application_form,
      candidate: carried_over_candidate,
      recruitment_cycle_year: RecruitmentCycle.current_year,
    )

    create(
      :application_form,
      candidate: recruited_candidate,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
      application_choices: [build(:application_choice, :recruited)],
    )

    [unsubmitted_candidate, rejected_candidate, carried_over_candidate, recruited_candidate]
  end

  describe '#perform' do
    context "it is time to send the 'new cycle has started' email" do
      it 'sends emails to candidates who have unsuccessful or unsubmitted applications from the previous cycle' do
        allow(EmailTimetable).to receive(:send_new_cycle_has_started_email?).and_return(true)

        unsubmitted_candidate, rejected_candidate, carried_over_candidate, recruited_candidate = setup_candidates

        described_class.new.perform

        email_for_unsubmitted_candidate = email_for_candidate(unsubmitted_candidate)
        email_for_rejected_candidate = email_for_candidate(rejected_candidate)
        email_for_carried_over_candidate = email_for_candidate(carried_over_candidate)
        email_for_recruited_candidate = email_for_candidate(recruited_candidate)

        expect(email_for_unsubmitted_candidate).to be_present
        expect(email_for_rejected_candidate).to be_present
        expect(email_for_carried_over_candidate).not_to be_present
        expect(email_for_recruited_candidate).not_to be_present
      end
    end

    context "it is not time to send the 'new cycle has started' email" do
      it 'does not send the email' do
        allow(EmailTimetable).to receive(:send_new_cycle_has_started_email?).and_return(false)
        setup_candidates

        described_class.new.perform

        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "it is time to send the 'new cycle has started' email but one candidate has already received it" do
      it 'does not send the email' do
        allow(EmailTimetable).to receive(:send_new_cycle_has_started_email?).and_return(true)
        allow(CycleTimetable).to receive(:apply_opens).and_return(1.day.ago)
        unsubmitted_candidate, rejected_candidate, carried_over_candidate, recruited_candidate = setup_candidates
        unsubmitted_candidate.current_application.chasers_sent.create(
          chaser_type: :new_cycle_has_started,
        )

        described_class.new.perform

        expect(email_for_candidate(unsubmitted_candidate)).not_to be_present
        expect(email_for_candidate(carried_over_candidate)).not_to be_present
        expect(email_for_candidate(recruited_candidate)).not_to be_present
        expect(email_for_candidate(rejected_candidate)).to be_present
      end
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
