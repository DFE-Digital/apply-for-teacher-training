require 'rails_helper'

RSpec.describe CancelUnsubmittedApplicationsWorker do
  describe '#perform' do
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

    let(:hidden_application_from_this_year) do
      create(:application_form,
             submitted_at: nil,
             candidate: create(:candidate, hide_in_reporting: true),
             recruitment_cycle_year: RecruitmentCycle.current_year,
             application_choices: [create_an_application_choice(:unsubmitted, current_year_course_option)])
    end

    let(:rejected_application_from_this_year) do
      create(:application_form,
             recruitment_cycle_year: RecruitmentCycle.current_year,
             application_choices: [create_an_application_choice(:rejected, current_year_course_option)])
    end

    let(:unsubmitted_cancelled_application_from_this_year) do
      create(:application_form,
             submitted_at: nil,
             recruitment_cycle_year: RecruitmentCycle.current_year,
             application_choices: [create_an_application_choice(:application_not_sent, current_year_course_option)])
    end

    let(:create_test_applications) do
      unsubmitted_cancelled_application_from_this_year
      rejected_application_from_this_year
      hidden_application_from_this_year
      unsubmitted_application_from_last_year
      unsubmitted_application_from_this_year
    end

    context 'for previous cycle, current cycle, next cycle' do
      [RecruitmentCycle.previous_year, RecruitmentCycle.current_year, RecruitmentCycle.next_year].each do |year|
        context 'on cancel application deadline', time: cancel_application_deadline(year) do
          it 'cancels applications' do
            create_test_applications

            described_class.new.perform

            expect(unsubmitted_application_from_this_year.reload.application_choices.first).to be_application_not_sent
            expect(unsubmitted_application_from_last_year.reload.application_choices.first).not_to be_application_not_sent
            expect(rejected_application_from_this_year.reload.application_choices.first).not_to be_application_not_sent
            expect(hidden_application_from_this_year.reload.application_choices.first).to be_application_not_sent
            expect(unsubmitted_cancelled_application_from_this_year.reload.application_choices.first).to be_application_not_sent
          end
        end

        context 'between cycles, but not on cancel date', time: after_apply_deadline(year) do
          it 'does not cancel any applications' do
            create_test_applications

            task = described_class.new.perform

            expect(task).to eq []
          end
        end

        context 'in mid-cycle', time: mid_cycle(year) do
          it 'does not run once in the middle of a cycle' do
            create_test_applications

            task = described_class.new.perform

            expect(task).to eq []
          end
        end

        context 'after_apply_reopens', time: after_apply_reopens(year) do
          it 'does not run once the new cycle starts' do
            create_test_applications

            task = described_class.new.perform

            expect(task).to eq []
          end
        end
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
