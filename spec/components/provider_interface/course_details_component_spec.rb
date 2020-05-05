require 'rails_helper'

RSpec.describe ProviderInterface::CourseDetailsComponent do
  let(:application_choice) {
    create(:application_choice,
           course: create(:course, funding_type: 'fee'))
  }

  let(:application_choice_with_accredited_body) {
    create(:application_choice,
           course: create(:course, :accredited_provider))
  }

  let(:render) { render_inline(described_class.new(application_choice: application_choice)) }

  it 'renders the provider name and code' do
    expect(render.css('.govuk-summary-list__row')[0].text).to include('Provider')
    expect(render.css('.govuk-summary-list__row')[0].text).to include(application_choice.provider.name_and_code)
  end

  context 'when an accredited body is present' do
    it 'renders the accredited body name and code when it is present' do
      render = render_inline(described_class.new(application_choice: application_choice_with_accredited_body))
      expect(render.css('.govuk-summary-list__row')[1].text).to include('Accredited body')
      expect(render.css('.govuk-summary-list__row')[1].text).to include(application_choice_with_accredited_body.course.accredited_provider.name)
    end
  end

  context 'when an accredited body is not present' do
    it 'renders the provider name and code in place of the accredited body name and code' do
      expect(render.css('.govuk-summary-list__row')[1].text).to include('Accredited body')
      expect(render.css('.govuk-summary-list__row')[1].text).to include(application_choice.provider.name_and_code)
    end
  end

  it 'renders the course name and code' do
    expect(render.css('.govuk-summary-list__row')[2].text).to include('Course')
    expect(render.css('.govuk-summary-list__row')[2].text).to include(application_choice.course.name_and_code)
  end

  it 'renders the recruitment cycle year' do
    expect(render.css('.govuk-summary-list__row')[3].text).to include('Cycle')
    expect(render.css('.govuk-summary-list__row')[3].text).to include(application_choice.course.recruitment_cycle_year.to_s)
  end

  it 'renders the preferred location' do
    expect(render.css('.govuk-summary-list__row')[4].text).to include('Preferred location')
    expect(render.css('.govuk-summary-list__row')[4].text).to include(application_choice.site.name_and_code)
  end

  it 'renders the study mode' do
    expect(render.css('.govuk-summary-list__row')[5].text).to include('Full or part time')
    expect(render.css('.govuk-summary-list__row')[5].text).to include(application_choice.course_option.study_mode.humanize)
  end

  it 'renders financing funding type of a course' do
    expect(render.css('.govuk-summary-list__row')[6].text).to include('Funding type')
    expect(render.css('.govuk-summary-list__row')[6].text).to include('Fee paying')
  end
end
