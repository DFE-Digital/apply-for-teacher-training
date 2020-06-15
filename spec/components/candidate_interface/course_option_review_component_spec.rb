require 'rails_helper'

RSpec.describe CandidateInterface::CourseOptionReviewComponent do
  it 'displays the course name, qualification type, location and study_mode' do
    provider = create(:provider)
    site = create(:site, provider: provider)
    course = create(:course, provider: provider)
    course_option = create(:course_option, site: site, course: course)

    result = render_inline(
      described_class.new(course_option: course_option),
    )

    expect(result.text).to include course.name
    expect(result.text).to include course.description
    expect(result.text).to include site.name_and_address
    expect(result.text).to include course_option.study_mode.humanize
  end
end
