require 'rails_helper'

RSpec.describe CandidateInterface::RejectionReasonsComponent do
  let(:application_form) { create(:completed_application_form) }
  let!(:application_choice) { create(:application_choice, :with_rejection, application_form: application_form) }

  it 'renders component with correct values' do
    result = render_inline(described_class.new(application_form: application_form))

    expect(result.css('.app-summary-card__title').text).to include(application_choice.provider.name)
    expect(result.css('.govuk-summary-list__key').text).to include('Course')
    expect(result.css('.govuk-summary-list__value').to_html).to include(application_choice.course.name_and_code)
    expect(result.css('.govuk-summary-list__value').to_html).to include(application_choice.course.description)
    expect(result.css('.govuk-summary-list__key').text).to include('Feedback')
    expect(result.css('.govuk-summary-list__value').to_html).to include(application_choice.rejection_reason)
    expect(result.css('a').to_html).to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course.code}")
  end

  context 'when Find is down' do
    it 'removes the link to Find' do
      Timecop.travel(EndOfCycleTimetable.find_closes.end_of_day + 1.hour) do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-summary-list__value').to_html).to include("#{application_choice.course.name} (#{application_choice.course.code})")
        expect(result.css('a').to_html).not_to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course.code}")
      end
    end
  end
end
