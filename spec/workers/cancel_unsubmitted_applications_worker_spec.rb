require 'rails_helper'

RSpec.describe CancelUnsubmittedApplicationsWorker do
  describe '#perform', time: after_apply_2_deadline do
    let(:unsubmitted_application_from_this_year) do
      create(:application_form,
             submitted_at: nil,
             recruitment_cycle_year: RecruitmentCycle.current_year,
             application_choices: [create_an_application_choice(:unsubmitted, current_year_course_option)])
    end

    let(:unsubmitted_application_from_last_year) do
      create(:application_form,
             submitted_at: nil,
             recruitment_cycle_year: RecruitmentCycle.previous_year,
             application_choices: [create_an_application_choice(:unsubmitted, previous_year_course_option)])
    end

    let(:previous_year_course_option) do
      create(:course_option,
             course: create(:course,
                            recruitment_cycle_year: RecruitmentCycle.previous_year))
    end

    let(:current_year_course_option) do
      create(:course_option,
             course: create(:course,
                            recruitment_cycle_year: RecruitmentCycle.current_year))
    end

    it 'cancels any unsubmitted applications from the last cycle' do
      unsubmitted_application_from_this_year
      unsubmitted_application_from_last_year

      hidden_application_from_this_year = create(
        :application_form,
        submitted_at: nil,
        candidate: create(:candidate, hide_in_reporting: true),
        recruitment_cycle_year: RecruitmentCycle.current_year,
        application_choices: [create_an_application_choice(:unsubmitted, current_year_course_option)],
      )

      rejected_application_from_this_year = create(
        :application_form,
        recruitment_cycle_year: RecruitmentCycle.current_year,
        application_choices: [create_an_application_choice(:rejected, current_year_course_option)],
      )

      unsubmitted_cancelled_application_from_this_year = create(
        :application_form,
        submitted_at: nil,
        recruitment_cycle_year: RecruitmentCycle.current_year,
        application_choices: [create_an_application_choice(:application_not_sent, current_year_course_option)],
      )

      described_class.new.perform

      expect(unsubmitted_application_from_this_year.reload.application_choices.first).to be_application_not_sent
      expect(unsubmitted_application_from_last_year.reload.application_choices.first).not_to be_application_not_sent
      expect(rejected_application_from_this_year.reload.application_choices.first).not_to be_application_not_sent
      expect(hidden_application_from_this_year.reload.application_choices.first).not_to be_application_not_sent
      expect(unsubmitted_cancelled_application_from_this_year.reload.application_choices.first).to be_application_not_sent
    end

    it 'does not run once in the new cycle' do
      travel_temporarily_to(CycleTimetable.apply_opens) do
        unsubmitted_application_from_this_year
        unsubmitted_application_from_last_year

        task = described_class.new.perform

        expect(task).to eq []
      end
    end
  end

  def create_an_application_choice(status, course_option)
    create(
      :application_choice,
      status: status,
      course_option: course_option,
    )
  end
end
