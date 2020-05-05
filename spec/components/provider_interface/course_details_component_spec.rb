require 'rails_helper'

RSpec.describe ProviderInterface::CourseDetailsComponent do
  let(:application_choice) {
    create(:application_choice,
           course: create(:course, funding_type: 'fee'))
  }

  let(:accredited_provider) { create(:provider) }

  let(:application_choice_with_accredited_body) {
    create(:application_choice,
           course: create(:course, accredited_provider: accredited_provider))
  }

  let(:render) { render_inline(described_class.new(application_choice: application_choice)) }

  def row_text_selector(row_name, render)
    rows = { provider: 0,
             accredited_body: 1,
             course: 2,
             cycle: 3,
             location: 4,
             full_or_part_time: 5,
             funding_type: 6 }

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  it 'renders the provider name and code' do
    render_text = row_text_selector(:provider, render)

    expect(render_text).to include('Provider')
    expect(render_text).to include(application_choice.provider.name_and_code)
  end

  context 'when an accredited body is present' do
    it 'renders the accredited body name and code when it is present' do
      render = render_inline(described_class.new(application_choice: application_choice_with_accredited_body))

      render_text = row_text_selector(:accredited_body, render)

      expect(render_text).to include('Accredited body')
      expect(render_text).to include(application_choice_with_accredited_body.course.accredited_provider.name)
    end
  end

  context 'when an accredited body is not present' do
    it 'renders the provider name and code in place of the accredited body name and code' do
      render_text = row_text_selector(:accredited_body, render)

      expect(render_text).to include('Accredited body')
      expect(render_text).to include(application_choice.provider.name_and_code)
    end
  end

  it 'renders the course name and code' do
    render_text = row_text_selector(:course, render)

    expect(render_text).to include('Course')
    expect(render_text).to include(application_choice.course.name_and_code)
  end

  it 'renders the recruitment cycle year' do
    render_text = row_text_selector(:cycle, render)

    expect(render_text).to include('Cycle')
    expect(render_text).to include(application_choice.course.recruitment_cycle_year.to_s)
  end

  it 'renders the preferred location' do
    render_text = row_text_selector(:location, render)

    expect(render_text).to include('Preferred location')
    expect(render_text).to include(application_choice.site.name_and_code)
  end

  it 'renders the study mode' do
    render_text = row_text_selector(:full_or_part_time, render)

    expect(render_text).to include('Full or part time')
    expect(render_text).to include(application_choice.course_option.study_mode.humanize)
  end

  it 'renders financing funding type of a course' do
    render_text = row_text_selector(:funding_type, render)

    expect(render_text).to include('Funding type')
    expect(render_text).to include('Fee paying')
  end
end
