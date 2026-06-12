require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesWorker do
  describe '#perform' do
    it 'enqueues a batch email job' do
      travel_temporarily_to(first_reminder_date) do
        SolidQueue::Job.delete_all

        reference_time = Time.zone.now

        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: current_year,
        )

        described_class.perform_now

        job = batch_jobs.first

        expect(job).to be_present
        expect(job.scheduled_at).to be_within(1.minute).of(reference_time)
      end
    end

    it 'does not return an application where the candidate account is locked' do
      travel_temporarily_to(first_reminder_date) do
        SolidQueue::Job.delete_all

        unsubscribed_candidate = create(:candidate, account_locked: true)
        create(:application_form, candidate: unsubscribed_candidate)

        described_class.new.perform

        expect(batch_jobs).to be_empty
      end
    end

    it 'does not return an application where the candidate is unsubscribed' do
      travel_temporarily_to(first_reminder_date) do
        SolidQueue::Job.delete_all

        unsubscribed_candidate = create(:candidate, unsubscribed_from_emails: true)
        create(:application_form, candidate: unsubscribed_candidate)

        described_class.new.perform

        expect(batch_jobs).to be_empty
      end
    end

    it 'does not return an application where the candidate submission is blocked' do
      travel_temporarily_to(first_reminder_date) do
        SolidQueue::Job.delete_all

        unsubscribed_candidate = create(:candidate, submission_blocked: true)
        create(:application_form, candidate: unsubscribed_candidate)

        described_class.new.perform

        expect(batch_jobs).to be_empty
      end
    end

    it 'returns an application for the second reminder date' do
      second_reminder_date = EndOfCycle::CandidateEmailTimetabler.email_schedule(:apply_deadline_second_reminder_date)
      travel_temporarily_to(second_reminder_date) do
        SolidQueue::Job.delete_all

        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: current_year,
        )

        described_class.new.perform

        expect(batch_jobs).to be_present
      end
    end

    it 'does not return an application when the deadline is 3 months away' do
      travel_temporarily_to(first_reminder_date - 1.month) do
        SolidQueue::Job.delete_all

        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: current_year,
        )

        described_class.new.perform

        expect(batch_jobs).to be_empty
      end
    end

    it 'does not return an application when the deadline has passed' do
      travel_temporarily_to(current_timetable.apply_deadline_at + 1.day) do
        SolidQueue::Job.delete_all

        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: current_year,
        )

        described_class.new.perform

        expect(batch_jobs).to be_empty
      end
    end

    it 'does not return an application form from the previous cycle' do
      travel_temporarily_to(first_reminder_date) do
        SolidQueue::Job.delete_all

        candidate = create(:candidate)

        create(
          :application_form,
          candidate:,
          application_choices: [create(:application_choice, :application_not_sent)],
          recruitment_cycle_year: previous_year,
        )

        described_class.new.perform

        expect(batch_jobs).to be_empty
      end
    end
  end

  def first_reminder_date
    @first_reminder_date ||= EndOfCycle::CandidateEmailTimetabler.email_schedule(:apply_deadline_first_reminder_date)
  end

  def batch_jobs
    SolidQueue::Job.where(class_name: 'SendEocDeadlineReminderEmailToCandidatesBatchWorker')
  end
end
