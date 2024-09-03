require 'rails_helper'

RSpec.describe SupportInterface::CourseOptionDetailsComponent do
  it 'renders postgraduate course' do
    postgraduate_course_option = create(:course_option)
    result = render_inline(described_class.new(course_option: postgraduate_course_option))
    expect(result.css('.govuk-summary-list__key').text).to include('Course type')
    expect(result.css('.govuk-summary-list__value').text).to include('Postgraduate')
  end

  it 'renders undergraduate course' do
    undergraduate_course_option = create(:course_option, course: create(:course, :teacher_degree_apprenticeship))
    result = render_inline(described_class.new(course_option: undergraduate_course_option))
    expect(result.css('.govuk-summary-list__key').text).to include('Course type')
    expect(result.css('.govuk-summary-list__value').text).to include('Undergraduate')
  end
end
