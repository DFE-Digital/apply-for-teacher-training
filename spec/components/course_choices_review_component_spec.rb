require 'rails_helper'

RSpec.describe CourseChoicesReviewComponent do
  let(:application_form) do
    create(:completed_application_form, application_choices_count: 2)
  end

  context 'when course choices are editable' do
    it 'renders component with correct values for a course' do
      course_choice = application_form.application_choices.first
      result = render_inline(CourseChoicesReviewComponent, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include(course_choice.provider.name)
      expect(result.css('.govuk-summary-list__key').text).to include('Course')
      expect(result.css('.govuk-summary-list__value').to_html).to include("#{course_choice.course.name} (#{course_choice.course.code})")
    end

    it 'renders component with correct values for a location' do
      course_choice = application_form.application_choices.first
      result = render_inline(CourseChoicesReviewComponent, application_form: application_form)

      expect(result.css('.govuk-summary-list__key').text).to include('Location')
      expect(result.css('.govuk-summary-list__value').to_html).to include(course_choice.site.name)
    end

    it 'renders component along with a delete link for each course' do
      course_id = application_form.application_choices.first.id
      result = render_inline(CourseChoicesReviewComponent, application_form: application_form)

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.courses.delete'))
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_destroy_course_choice_path(course_id),
      )
    end

    it 'renders component with correct values for multiple courses' do
      result = render_inline(CourseChoicesReviewComponent, application_form: application_form)

      application_form.application_choices.each do |course_choice|
        expect(result.css('.app-summary-card__title').text).to include(course_choice.provider.name)
      end
    end
  end

  context 'when course choices are not editable' do
    it 'renders component without a delete link and with a withdraw link' do
      result = render_inline(CourseChoicesReviewComponent, application_form: application_form, editable: false)

      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.courses.delete'))
      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.courses.withdraw'))
    end
  end
end
