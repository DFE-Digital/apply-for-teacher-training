require 'rails_helper'

RSpec.describe SubmittedCourseChoicesComponent do
  let(:application_form) do
    create(:completed_application_form, application_choices_count: 1)
  end

  it 'renders component with correct values for a course' do
    course_choice = application_form.application_choices.first
    result = render_inline(SubmittedCourseChoicesComponent, application_form: application_form)

    expect(result.css('.app-summary-card__title').text).to include(course_choice.provider.name)
    expect(result.css('.govuk-summary-list__key').text).to include('Course')
    expect(result.css('.govuk-summary-list__value').to_html).to include("#{course_choice.course.name} (#{course_choice.course.code})")
  end

  it 'renders component with correct values for a location' do
    course_choice = application_form.application_choices.first
    result = render_inline(SubmittedCourseChoicesComponent, application_form: application_form)

    expect(result.css('.govuk-summary-list__key').text).to include('Location')
    expect(result.css('.govuk-summary-list__value').to_html).to include(course_choice.site.name)
  end
end
