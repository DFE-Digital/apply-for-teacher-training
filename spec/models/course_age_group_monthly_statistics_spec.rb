require 'rails_helper'

RSpec.describe CourseAgeGroupMonthlyStatistics do
  subject(:statistics) { described_class.new.call }

  it 'returns a hash of application choice status totals by course age group' do
    create_application_choice(status: :with_rejection, course_level: 'primary')
    create_application_choice(status: :with_offer, course_level: 'secondary')
    create_application_choice(status: :with_conditions_not_met, course_level: 'further_education')
    create_application_choice(status: :with_recruited, course_level: 'primary')
    create_application_choice(status: :with_conditions_not_met, course_level: 'secondary')

    expect(statistics).to eq(
      {
        'Primary' => {
          'recruited' => 1,
          'rejected' => 1,
          'total' => 2,
        },
        'Secondary' => {
          'conditions_not_met' => 1,
          'offer' => 1,
          'total' => 2,
        },
        'Further education' => {
          'conditions_not_met' => 1,
          'total' => 1,
        },
      },
    )
  end

  def create_application_choice(status:, course_level:)
    create(:application_choice, status, course_option: create(:course_option, course: create(:course, level: course_level)))
  end
end
