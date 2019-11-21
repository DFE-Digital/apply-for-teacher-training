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

  context 'when course choices are submitted' do
    it 'renders component with the status as submitted when awaiting references' do
      application_form = create_application_form_with_course_choice(status: 'awaiting_references')

      result = render_inline(CourseChoicesReviewComponent, application_form: application_form, editable: false, show_status: true)

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Submitted')
    end

    it 'renders component with the status as submitted when application is complete' do
      application_form = create_application_form_with_course_choice(status: 'application_complete')

      result = render_inline(CourseChoicesReviewComponent, application_form: application_form, editable: false, show_status: true)

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Submitted')
    end

    it 'renders component with the status as pending when awaiting provider decision' do
      application_form = create_application_form_with_course_choice(status: 'awaiting_provider_decision')

      result = render_inline(CourseChoicesReviewComponent, application_form: application_form, editable: false, show_status: true)

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Pending')
    end

    it 'renders component with the status as offer when an offer has been made' do
      application_form = create_application_form_with_course_choice(status: 'offer')

      result = render_inline(CourseChoicesReviewComponent, application_form: application_form, editable: false, show_status: true)

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer')
    end

    it 'renders component with the status as accepted when the candidate has accepted an offer' do
      application_form = create_application_form_with_course_choice(status: 'pending_conditions')

      result = render_inline(CourseChoicesReviewComponent, application_form: application_form, editable: false, show_status: true)

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Accepted')
    end

    it 'renders component with the status as accepted when the candidate has declined an offer' do
      application_form = create_application_form_with_course_choice(status: 'declined')

      result = render_inline(CourseChoicesReviewComponent, application_form: application_form, editable: false, show_status: true)

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Declined')
    end
  end

  def create_application_form_with_course_choice(status:)
    application_form = create(:application_form)

    create(
      :application_choice,
      application_form: application_form,
      status: status,
    )

    application_form
  end
end
