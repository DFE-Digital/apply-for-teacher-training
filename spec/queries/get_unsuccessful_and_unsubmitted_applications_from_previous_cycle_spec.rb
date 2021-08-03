require 'rails_helper'

RSpec.describe GetUnsuccessfulAndUnsubmittedApplicationsFromPreviousCycle do
  describe '.call' do
    it 'returns unsuccessful and unsubmitted applications from the previous cycle' do
      application_form_current_year = create(:application_form, :minimum_info, recruitment_cycle_year: RecruitmentCycle.current_year)
      application_form_previous_year = create(:application_form, submitted_at: 1.year.ago, recruitment_cycle_year: RecruitmentCycle.previous_year)

      rejected_application_choice_from_previous_cycle = create(:application_choice, :with_rejection, :previous_year, application_form: application_form_previous_year)
      unsubmitted_application_from_previous_cycle = create(:application_form, submitted_at: nil, recruitment_cycle_year: RecruitmentCycle.previous_year)

      create(:application_choice, :with_offer, :previous_year, application_form: application_form_previous_year)
      create(:application_choice, :with_rejection, application_form: application_form_current_year)

      unsuccessful_and_unsubmitted_applications = described_class.call

      expect(unsuccessful_and_unsubmitted_applications.count).to eq(2)
      expect(unsuccessful_and_unsubmitted_applications.map(&:id))
        .to match_array(
          [
            unsubmitted_application_from_previous_cycle.id,
            rejected_application_choice_from_previous_cycle.application_form.id,
          ],
        )
    end
  end
end
