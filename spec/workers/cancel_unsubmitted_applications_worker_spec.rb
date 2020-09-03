require 'rails_helper'

RSpec.describe CancelUnsubmittedApplicationsWorker do
  describe '#perform' do
    it 'cancels any unsubmitted applications from the last cycle' do
      unsubmitted_application_from_last_year = create(
        :completed_application_form,
        submitted_at: nil,
        recruitment_cycle_year: RecruitmentCycle.previous_year,
      )
      create(
        :application_choice,
        status: :unsubmitted,
        application_form: unsubmitted_application_from_last_year,
        course_option: create(:course_option, course: create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year)),
      )

      hidden_application_from_last_year = create(
        :completed_application_form,
        submitted_at: nil,
        candidate: create(:candidate, hide_in_reporting: true),
        recruitment_cycle_year: RecruitmentCycle.previous_year,
      )
      create(
        :application_choice,
        status: :unsubmitted,
        application_form: hidden_application_from_last_year,
        course_option: create(:course_option, course: create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year)),
      )

      unsubmitted_application_from_this_year = create(
        :completed_application_form,
        submitted_at: nil,
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      create(
        :application_choice,
        status: :unsubmitted,
        application_form: unsubmitted_application_from_this_year,
        course_option: create(:course_option, course: create(:course, recruitment_cycle_year: RecruitmentCycle.current_year)),
      )

      rejected_application_from_last_year = create(
        :completed_application_form,
        recruitment_cycle_year: RecruitmentCycle.previous_year,
      )
      create(
        :application_choice,
        status: :rejected,
        application_form: rejected_application_from_last_year,
        course_option: create(:course_option, course: create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year)),
      )

      described_class.new.perform

      expect(unsubmitted_application_from_last_year.reload.application_choices.first).to be_cancelled

      expect(unsubmitted_application_from_this_year.reload.application_choices.first).not_to be_cancelled
      expect(rejected_application_from_last_year.reload.application_choices.first).not_to be_cancelled
      expect(hidden_application_from_last_year.reload.application_choices.first).not_to be_cancelled
    end
  end
end
