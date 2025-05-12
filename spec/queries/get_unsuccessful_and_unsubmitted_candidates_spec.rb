require 'rails_helper'

RSpec.describe GetUnsuccessfulAndUnsubmittedCandidates do
  describe '.call' do
    it 'returns unsuccessful and unsubmitted applications from the previous cycle' do
      candidate_with_submission_blocked = create(:candidate, submission_blocked: true)
      candidate_with_account_locked = create(:candidate, account_locked: true)
      candidate_unsubscribed_from_emails = create(:candidate, unsubscribed_from_emails: true)

      accepted_application_form_from_previous_cycle = create(:application_form, :submitted, recruitment_cycle_year: current_timetable.relative_previous_year)
      create(:application_choice, :accepted, application_form: accepted_application_form_from_previous_cycle)

      create(:application_form, candidate: candidate_with_submission_blocked, recruitment_cycle_year: current_timetable.relative_previous_year)
      create(:application_form, candidate: candidate_with_account_locked, recruitment_cycle_year: current_timetable.relative_previous_year)
      create(:application_form, candidate: candidate_unsubscribed_from_emails, recruitment_cycle_year: current_timetable.relative_previous_year)

      rejected_application_form_from_previous_cycle = create(
        :application_form,
        :minimum_info,
        recruitment_cycle_year: current_timetable.relative_previous_year,
      )

      create(:application_choice, :rejected, application_form: rejected_application_form_from_previous_cycle)

      carried_over_application_form = create(
        :application_form,
        :minimum_info,
        recruitment_cycle_year: current_timetable.recruitment_cycle_year,
        candidate: rejected_application_form_from_previous_cycle.candidate,
      )

      application_form_current_year = create(:application_form, :minimum_info, submitted_at: nil, recruitment_cycle_year: current_timetable.recruitment_cycle_year)

      application_form_previous_year = create(:application_form, submitted_at: 1.year.ago, recruitment_cycle_year: current_timetable.relative_previous_year)

      create(:application_choice, :rejected, application_form: application_form_previous_year)

      another_application_form_from_previous_year = create(:application_form, submitted_at: 1.year.ago, recruitment_cycle_year: current_timetable.relative_previous_year)
      create(:application_choice, :recruited, application_form: another_application_form_from_previous_year)

      rejected_application_choice_from_previous_cycle = create(:application_choice, :rejected, :previous_year, application_form: application_form_previous_year)
      unsubmitted_application_from_previous_cycle = create(:application_form, submitted_at: nil, recruitment_cycle_year: current_timetable.relative_previous_year)

      unsuccessful_and_unsubmitted_applications = described_class.call

      expect(unsuccessful_and_unsubmitted_applications.count).to eq(4)
      expect(unsuccessful_and_unsubmitted_applications)
        .to contain_exactly(
          carried_over_application_form.candidate,
          application_form_current_year.candidate,
          unsubmitted_application_from_previous_cycle.candidate,
          rejected_application_choice_from_previous_cycle.application_form.candidate,
        )
    end

    it 'does not return candidates who have unsubscribed_from_emails' do
      unsubscribed_candidate = create(:candidate, unsubscribed_from_emails: true)
      create(:application_form, :minimum_info, candidate: unsubscribed_candidate)

      expect(described_class.call).to be_empty
    end
  end
end
