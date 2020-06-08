require 'rails_helper'

RSpec.describe GetApplicationChoicesWithNewlyUnavailableCourses do
  include CourseOptionHelpers

  it 'returns an application choice for a course that has no vacancies' do
    application_choice_without_vacancies = create(
      :awaiting_references_application_choice,
      course_option: create(:course_option, :no_vacancies),
    )
    create :awaiting_references_application_choice
    expect(described_class.call.map(&:id)).to eq([application_choice_without_vacancies.id])
  end
end
