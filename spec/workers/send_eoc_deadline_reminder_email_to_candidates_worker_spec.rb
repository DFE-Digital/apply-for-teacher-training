require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesWorker, :sidekiq do
  describe '#perform' do
    it 'returns an application on the reminder date' do
      travel_temporarily_to(first_reminder_date) do
        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
        )

        described_class.new.perform

        email_for_candidate = email_for_candidate(candidate)

        expect(email_for_candidate).to be_present
      end
    end

    it 'does not return an application where the candidate account is locked' do
      travel_temporarily_to(first_reminder_date) do
        unsubscribed_candidate = create(:candidate, account_locked: true)
        create(:application_form, candidate: unsubscribed_candidate)

        described_class.new.perform

        email_for_candidate = email_for_candidate(unsubscribed_candidate)

        expect(email_for_candidate).not_to be_present
      end
    end

    it 'does not return an application where the candidate is unsubscribed' do
      travel_temporarily_to(first_reminder_date) do
        unsubscribed_candidate = create(:candidate, unsubscribed_from_emails: true)
        create(:application_form, candidate: unsubscribed_candidate)

        described_class.new.perform

        email_for_candidate = email_for_candidate(unsubscribed_candidate)

        expect(email_for_candidate).not_to be_present
      end
    end

    it 'does not return an application where the candidate submission is blocked' do
      travel_temporarily_to(first_reminder_date) do
        unsubscribed_candidate = create(:candidate, submission_blocked: true)
        create(:application_form, candidate: unsubscribed_candidate)

        described_class.new.perform

        email_for_candidate = email_for_candidate(unsubscribed_candidate)

        expect(email_for_candidate).not_to be_present
      end
    end

    it 'returns an application for the second reminder ate away' do
      second_reminder_date = EndOfCycle::CandidateEmailTimetabler.email_schedule(:apply_deadline_second_reminder_date)
      travel_temporarily_to(second_reminder_date) do
        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
        )

        described_class.new.perform

        email_for_candidate = email_for_candidate(candidate)

        expect(email_for_candidate).to be_present
      end
    end

    it 'does not return an application when the deadline is 3 months away' do
      travel_temporarily_to(first_reminder_date - 1.month) do
        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
        )

        described_class.new.perform

        email_for_candidate = email_for_candidate(candidate)

        expect(email_for_candidate).not_to be_present
      end
    end

    it 'does not return an application when the deadline has passed' do
      travel_temporarily_to(RecruitmentCycleTimetable.current_timetable.apply_deadline_at + 1.day) do
        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
        )

        described_class.new.perform

        email_for_candidate = email_for_candidate(candidate)

        expect(email_for_candidate).not_to be_present
      end
    end

    it 'does not return an application form from the previous cycle' do
      travel_temporarily_to(first_reminder_date) do
        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: RecruitmentCycle.previous_year,
        )

        described_class.new.perform

        email_for_candidate = email_for_candidate(candidate)

        expect(email_for_candidate).not_to be_present
      end
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end

  def first_reminder_date
    @first_reminder_date ||= EndOfCycle::CandidateEmailTimetabler.email_schedule(:apply_deadline_first_reminder_date)
  end
end
