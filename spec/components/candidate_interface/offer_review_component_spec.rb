require 'rails_helper'

RSpec.describe CandidateInterface::OfferReviewComponent do
  include CourseOptionHelpers

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_form) { create(:application_form, submitted_at: Time.zone.now) }
  let(:application_choice) do
    create(
      :application_choice,
      status: 'offer',
      offer: { 'conditions' => ['Fitness to train to teach check', 'Be cool'] },
      course_option: course_option,
      application_form: application_form,
    )
  end
  let(:find_closes) { EndOfCycleTimetable::CYCLE_DATES.dig(Time.zone.now.year, :find_closes) }

  it 'renders component with correct values for the provider' do
    result = render_inline(described_class.new(course_choice: application_choice))

    expect(result.css('.govuk-summary-list__key').text).to include('Provider')
    expect(result.css('.govuk-summary-list__value').text).to include(course_option.course.provider.name)
  end

  context 'when Find is open' do
    it 'renders component with correct values for the course' do
      Timecop.freeze(find_closes) do
        result = render_inline(described_class.new(course_choice: application_choice))

        expect(result.css('.govuk-summary-list__key').text).to include('Course')
        expect(result.css('.govuk-summary-list__value').text).to include(
          "#{course_option.course.name} (#{course_option.course.code})",
        )
        expect(result.css('a').to_html).to include(course_option.course.find_url)
      end
    end
  end

  context 'when Find is closed' do
    it 'renders component with correct values for the course' do
      Timecop.freeze(find_closes + 1.day) do
        result = render_inline(described_class.new(course_choice: application_choice))

        expect(result.css('.govuk-summary-list__key').text).to include('Course')
        expect(result.css('.govuk-summary-list__value').text).to include(
          "#{course_option.course.name} (#{course_option.course.code})",
        )
        expect(result.css('a').to_html).not_to include(course_option.course.find_url)
      end
    end
  end

  it 'renders component with correct values for the location' do
    result = render_inline(described_class.new(course_choice: application_choice))

    expect(result.css('.govuk-summary-list__value').text).to include(course_option.site.name)
  end

  it 'renders component with correct values for the conditions' do
    result = render_inline(described_class.new(course_choice: application_choice))

    expect(result.css('.govuk-summary-list__key').text).to include('Conditions')
    expect(result.css('.govuk-summary-list__value').text).to include('Fitness to train to teach')
    expect(result.css('.govuk-summary-list__value').text).to include('Be cool')
  end
end
