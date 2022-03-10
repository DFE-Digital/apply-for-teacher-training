require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoicesReviewVisaStatusComponent do
  it 'renders component with warning' do
    application_choice = setup_application
    result = render_inline(described_class.new(application_choice: application_choice))

    expect(result.css('.app-inset-text__title').text).to include('Visa sponsorship is not available for this course')
  end

  def setup_application
    course_option = create(
      :course_option,
      course: create(
        :course,
        provider: create(
          :provider,
        ),
      ),
    )
    create(
      :application_choice,
      course_option: course_option,
    )
  end
end
