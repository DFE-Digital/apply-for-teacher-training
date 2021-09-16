require 'rails_helper'

RSpec.describe CourseAgeGroupMonthlyStatistics do
  subject(:statistics) { described_class.new.call }

  it 'returns a hash of application choice status totals by course age group' do
    # These statistics specs are going to end up slowing down the entire suite as they have to
    # create large amounts of records?
    create_application_choice(status: :with_rejection, course_level: 'primary')
    create_application_choice(status: :awaiting_provider_decision, course_level: 'primary')
    create_application_choice(status: :with_recruited, course_level: 'primary')
    create_application_choice(status: :with_offer, course_level: 'secondary')
    create_application_choice(status: :with_conditions_not_met, course_level: 'secondary')
    create_application_choice(status: :with_offer, course_level: 'further_education')
    create_application_choice(status: :with_rejection, course_level: 'further_education')

    expect(statistics).to eq(
      { rows:
        [
          {
            'Age group' => 'Primary',
            'Recruited' => 1,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 1,
            'Unsuccessful' => 1,
            'Total' => 3,
          },
          {
            'Age group' => 'Secondary',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Age group' => 'Further education',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 2,
          },
        ],
        column_totals: [1, 0, 2, 1, 2, 6] },
    )
  end

  def create_application_choice(status:, course_level:)
    create(:application_choice, status, course_option: create(:course_option, course: create(:course, level: course_level)))
  end
end
