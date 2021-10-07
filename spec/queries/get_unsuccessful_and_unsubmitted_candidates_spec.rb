require 'rails_helper'

RSpec.describe GetUnsuccessfulAndUnsubmittedCandidates do
  describe '.call' do
    it 'returns unsuccessful and unsubmitted applications from the previous cycle' do
      rejected_application_form_from_previous_cycle = create(
        :application_form,
        :minimum_info,
        recruitment_cycle_year: RecruitmentCycle.previous_year,
      )

      create(:application_choice, :with_rejection, application_form: rejected_application_form_from_previous_cycle)

      carried_over_application_form = create(
        :application_form,
        :minimum_info,
        recruitment_cycle_year: RecruitmentCycle.current_year,
        candidate: rejected_application_form_from_previous_cycle.candidate,
      )

      application_form_current_year = create(:application_form, :minimum_info, recruitment_cycle_year: RecruitmentCycle.current_year)

      application_form_previous_year = create(:application_form, submitted_at: 1.year.ago, recruitment_cycle_year: RecruitmentCycle.previous_year)

      create(:application_choice, :with_rejection, application_form: application_form_previous_year)
      create(:application_choice, :with_recruited, application_form: application_form_previous_year)

      rejected_application_choice_from_previous_cycle = create(:application_choice, :with_rejection, :previous_year)
      unsubmitted_application_from_previous_cycle = create(:application_form, submitted_at: nil, recruitment_cycle_year: RecruitmentCycle.previous_year)

      unsuccessful_and_unsubmitted_applications = described_class.call

      expect(unsuccessful_and_unsubmitted_applications.count).to eq(4)
      expect(unsuccessful_and_unsubmitted_applications.map(&:id))
        .to match_array(
          [
            carried_over_application_form.candidate.id,
            application_form_current_year.candidate.id,
            unsubmitted_application_from_previous_cycle.candidate.id,
            rejected_application_choice_from_previous_cycle.application_form.candidate.id,
          ],
        )
    end

    it 'does not return candidates who have unsubscribed_from_emails' do
      unsubscribed_candidate = create(:candidate, unsubscribed_from_emails: true)
      create(:application_form, :minimum_info, candidate: unsubscribed_candidate)

      expect(described_class.call).to be_empty
    end
  end
end
