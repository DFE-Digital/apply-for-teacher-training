require 'rails_helper'

RSpec.describe MonthlyStatistics::ByCourseAgeGroup do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course age group'" do
    setup_test_data

    expect(statistics).to eq({
      rows: [
        {
          'Age group' => 'Primary',
          'Recruited' => 1,
          'Conditions pending' => 0,
          'Received an offer' => 0,
          'Awaiting provider decisions' => 1,
          'Unsuccessful' => 1,
          'Total' => 3,
        },
        { 'Age group' => 'Secondary',
          'Recruited' => 0,
          'Conditions pending' => 1,
          'Received an offer' => 1,
          'Awaiting provider decisions' => 0,
          'Unsuccessful' => 2,
          'Total' => 4 },
        {
          'Age group' => 'Further education',
          'Recruited' => 0,
          'Conditions pending' => 0,
          'Received an offer' => 1,
          'Awaiting provider decisions' => 0,
          'Unsuccessful' => 2,
          'Total' => 3,
        },
      ],
      column_totals: [1, 1, 2, 1, 5, 10],
    })
  end

  def setup_test_data
    create(:application_choice, :with_offer, :offer_deferred, status_before_deferral: 'recruited', current_recruitment_cycle_year: RecruitmentCycle.previous_year, course_option: create(:course_option, course: create(:course, level: 'primary')))
    create(:application_choice, :with_offer, :offer_deferred, status_before_deferral: 'pending_conditions', current_recruitment_cycle_year: RecruitmentCycle.previous_year, course_option: create(:course_option, course: create(:course, level: 'secondary')))

    create(:application_choice, :with_rejection, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'primary')))
    create(:application_choice, :awaiting_provider_decision, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'primary')))
    create(:application_choice, :with_recruited, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'primary')))
    create(:application_choice, :with_offer, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'secondary')))
    create(:application_choice, :with_conditions_not_met, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'secondary')))
    create(:application_choice, :with_withdrawn_offer, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'secondary')))
    create(:application_choice, :with_offer, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'further_education')))
    create(:application_choice, :with_rejection, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'further_education')))
    create(:application_choice, :withdrawn, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'further_education')))
  end
end
