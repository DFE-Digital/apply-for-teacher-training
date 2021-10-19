require 'rails_helper'

RSpec.describe MonthlyStatistics::ByCourseType do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course age group'" do
    create_application_choice(status: :with_rejection, program_type: 'higher_education_programme')
    create_application_choice(status: :awaiting_provider_decision, program_type: 'higher_education_programme')
    create_application_choice(status: :with_recruited, program_type: 'higher_education_programme')
    create_application_choice(status: :with_offer, program_type: 'pg_teaching_apprenticeship')
    create_application_choice(status: :with_conditions_not_met, program_type: 'pg_teaching_apprenticeship')
    create_application_choice(status: :with_offer, program_type: 'scitt_programme')
    create_application_choice(status: :with_rejection, program_type: 'scitt_programme')
    create_application_choice(status: :with_offer, program_type: 'school_direct_training_programme')
    create_application_choice(status: :with_rejection, program_type: 'school_direct_training_programme')
    create_application_choice(status: :with_offer, program_type: 'school_direct_salaried_training_programme')
    create_application_choice(status: :with_rejection, program_type: 'school_direct_salaried_training_programme')

    expect(statistics).to eq(
      { rows:
        [
          {
            'Course type' => 'Higher education',
            'Recruited' => 1,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 1,
            'Unsuccessful' => 1,
            'Total' => 3,
          },
          {
            'Course type' => 'Postgraduate teaching apprenticeship',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 2,
          },
          {
            'Course type' => 'School-centred initial teacher training (SCITT)',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 2,
          },
          {
            'Course type' => 'School Direct (fee-paying)',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 2,
          },
          {
            'Course type' => 'School Direct (salaried)',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 2,
          },

        ],
        column_totals: [1, 0, 4, 1, 5, 11] },
    )
  end

  def create_application_choice(status:, program_type:)
    create(:application_choice, status, course_option: create(:course_option, course: create(:course, program_type: program_type)))
  end
end
