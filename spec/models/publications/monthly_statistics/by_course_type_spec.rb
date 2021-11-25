require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByCourseType do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course type'" do
    setup_test_data

    expect(statistics).to eq(
      { rows:
        [
          {
            'Course type' => 'Higher education',
            'Recruited' => 1,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 1,
            'Unsuccessful' => 2,
            'Total' => 4,
          },
          {
            'Course type' => 'Postgraduate teaching apprenticeship',
            'Recruited' => 0,
            'Conditions pending' => 1,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 2,
            'Total' => 4,
          },
          {
            'Course type' => 'School-centred initial teacher training (SCITT)',
            'Recruited' => 0,
            'Conditions pending' => 2,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 4,
          },
          {
            'Course type' => 'School Direct (fee-paying)',
            'Recruited' => 1,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 3,
          },
          {
            'Course type' => 'School Direct (salaried)',
            'Recruited' => 0,
            'Conditions pending' => 1,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 3,
          },

        ],
        column_totals: [2, 4, 4, 1, 7, 18] },
    )
  end

  def setup_test_data
    # previous year
    create_application_choice_for_last_cycle(status_before_deferral: 'recruited', program_type: 'higher_education_programme')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', program_type: 'pg_teaching_apprenticeship')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', program_type: 'scitt_programme')
    create_application_choice_for_last_cycle(status_before_deferral: 'recruited', program_type: 'school_direct_training_programme')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', program_type: 'school_direct_salaried_training_programme')

    # current year
    create_application_choice_for_this_cycle(status: :with_rejection, program_type: 'higher_education_programme')
    create_application_choice_for_this_cycle(status: :withdrawn, program_type: 'higher_education_programme')
    create_application_choice_for_this_cycle(status: :awaiting_provider_decision, program_type: 'higher_education_programme')
    create_application_choice_for_this_cycle(status: :with_offer, program_type: 'pg_teaching_apprenticeship')
    create_application_choice_for_this_cycle(status: :with_conditions_not_met, program_type: 'pg_teaching_apprenticeship')
    create_application_choice_for_this_cycle(status: :with_withdrawn_offer, program_type: 'pg_teaching_apprenticeship')
    create_application_choice_for_this_cycle(status: :with_offer, program_type: 'scitt_programme')
    create_application_choice_for_this_cycle(status: :with_rejection, program_type: 'scitt_programme')
    create_application_choice_for_this_cycle(status: :with_offer, program_type: 'school_direct_training_programme')
    create_application_choice_for_this_cycle(status: :with_rejection, program_type: 'school_direct_training_programme')
    create_application_choice_for_this_cycle(status: :with_offer, program_type: 'school_direct_salaried_training_programme')
    create_application_choice_for_this_cycle(status: :with_rejection, program_type: 'school_direct_salaried_training_programme')
    create_application_choice_for_this_cycle(status: :with_accepted_offer, program_type: 'scitt_programme')
  end

  def create_application_choice_for_this_cycle(status:, program_type:)
    create(:application_choice, status, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, program_type: program_type)))
  end

  def create_application_choice_for_last_cycle(status_before_deferral:, program_type:)
    create(:application_choice, :with_offer, :offer_deferred, status_before_deferral: status_before_deferral, current_recruitment_cycle_year: RecruitmentCycle.previous_year, course_option: create(:course_option, course: create(:course, program_type: program_type)))
  end
end
