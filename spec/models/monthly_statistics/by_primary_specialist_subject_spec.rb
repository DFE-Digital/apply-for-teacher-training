require 'rails_helper'

RSpec.describe MonthlyStatistics::ByPrimarySpecialistSubject do
  context 'applications by status table data' do
    subject(:statistics) { described_class.new.table_data }

    it "returns table data for 'applications by status'" do
      setup_test_data

      expect(statistics).to eq(
        {
          rows: [
            {
              'Subject' => 'English',
              'Recruited' => 0,
              'Conditions pending' => 1,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Geography and History',
              'Recruited' => 1,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Mathematics',
              'Recruited' => 0,
              'Conditions pending' => 1,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Modern languages',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 1,
              'Total' => 1,
            },
            {
              'Subject' => 'Physical Education',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 1,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Science',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 1,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'No specialist subject',
              'Recruited' => 1,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
          ],
          column_totals: [2, 2, 0, 2, 1, 7],
        },
      )
    end
  end

  def setup_test_data
    primary_course_option = create(:course_option, course: create(:course, level: 'primary', subjects: [create(:subject, name: 'Primary')]))
    primary_with_english_course_option = create(:course_option, course: create(:course, level: 'primary', subjects: [create(:subject, name: 'Primary with English')]))
    primary_with_mathematics_course_option = create(:course_option, course: create(:course, level: 'primary', subjects: [create(:subject, name: 'Primary with mathematics')]))
    primary_with_geography_and_history_course_option = create(:course_option, course: create(:course, level: 'primary', subjects: [create(:subject, name: 'Primary with geography and history')]))
    primary_with_modern_languages_course_option = create(:course_option, course: create(:course, level: 'primary', subjects: [create(:subject, name: 'Primary with modern languages')]))
    primary_with_science_course_option = create(:course_option, course: create(:course, level: 'primary', subjects: [create(:subject, name: 'Primary with science')]))
    primary_with_pe_course_option = create(:course_option, course: create(:course, level: 'primary', subjects: [create(:subject, name: 'Primary with physical education')]))

    # previous year
    create(:application_choice, :with_offer, :offer_deferred, status_before_deferral: 'recruited', current_recruitment_cycle_year: RecruitmentCycle.previous_year, course_option: primary_course_option)
    create(:application_choice, :with_offer, :offer_deferred, status_before_deferral: 'pending_conditions', current_recruitment_cycle_year: RecruitmentCycle.previous_year, course_option: primary_with_english_course_option)
    create(:application_choice, :with_offer, :offer_deferred, status_before_deferral: 'pending_conditions', current_recruitment_cycle_year: RecruitmentCycle.previous_year, course_option: primary_with_mathematics_course_option)

    # current year
    create(:application_choice, :with_recruited, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: primary_with_geography_and_history_course_option)
    create(:application_choice, :with_rejection, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: primary_with_modern_languages_course_option)
    create(:application_choice, :awaiting_provider_decision, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: primary_with_science_course_option)
    create(:application_choice, :awaiting_provider_decision, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: primary_with_pe_course_option)
  end
end
