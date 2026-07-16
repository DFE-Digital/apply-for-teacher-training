require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesWorker do
  describe '#perform' do
    it 'returns an application on the reminder date' do
      travel_temporarily_to(first_reminder_date) do
        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: current_year,
        )

        expect { described_class.perform_now }.to have_enqueued_job(SendEocDeadlineReminderEmailToCandidatesBatchWorker)
      end
    end

    it 'does not return an application where the candidate account is locked' do
      travel_temporarily_to(first_reminder_date) do
        unsubscribed_candidate = create(:candidate, account_locked: true)
        create(:application_form, candidate: unsubscribed_candidate)

        expect { described_class.new.perform }.not_to have_enqueued_job(SendEocDeadlineReminderEmailToCandidatesBatchWorker)
      end
    end

    it 'does not return an application where the candidate is unsubscribed' do
      travel_temporarily_to(first_reminder_date) do
        unsubscribed_candidate = create(:candidate, unsubscribed_from_emails: true)
        create(:application_form, candidate: unsubscribed_candidate)

        expect { described_class.new.perform }.not_to have_enqueued_job(SendEocDeadlineReminderEmailToCandidatesBatchWorker)
      end
    end

    it 'does not return an application where the candidate submission is blocked' do
      travel_temporarily_to(first_reminder_date) do
        unsubscribed_candidate = create(:candidate, submission_blocked: true)
        create(:application_form, candidate: unsubscribed_candidate)

        expect { described_class.new.perform }.not_to have_enqueued_job(SendEocDeadlineReminderEmailToCandidatesBatchWorker)
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
          recruitment_cycle_year: current_year,
        )

        expect { described_class.new.perform }.to have_enqueued_job(SendEocDeadlineReminderEmailToCandidatesBatchWorker)
      end
    end

    it 'does not return an application when the deadline is 3 months away' do
      travel_temporarily_to(first_reminder_date - 1.month) do
        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: current_year,
        )

        expect { described_class.new.perform }.not_to have_enqueued_job(SendEocDeadlineReminderEmailToCandidatesBatchWorker)
      end
    end

    it 'does not return an application when the deadline has passed' do
      travel_temporarily_to(current_timetable.apply_deadline_at + 1.day) do
        create(
          :application_form,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: current_year,
        )

        expect { described_class.new.perform }.not_to enqueue_job(SendEocDeadlineReminderEmailToCandidatesBatchWorker)
      end
    end

    it 'does not return an application form from the previous cycle' do
      travel_temporarily_to(first_reminder_date) do

        create(
          :application_form,
          application_choices: [build(:application_choice, :application_not_sent)],
          recruitment_cycle_year: previous_year,
        )

        expect { described_class.new.perform }.not_to have_enqueued_job(SendEocDeadlineReminderEmailToCandidatesBatchWorker)
      end
    end
  end

  def first_reminder_date
    @first_reminder_date ||= EndOfCycle::CandidateEmailTimetabler.email_schedule(:apply_deadline_first_reminder_date)
  end
end
