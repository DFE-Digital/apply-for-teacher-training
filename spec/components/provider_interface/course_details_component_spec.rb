require 'rails_helper'

RSpec.describe ProviderInterface::CourseDetailsComponent do
  let(:course_option) do
    instance_double(CourseOption,
                    study_mode: 'Full time')
  end

  let(:site) do
    instance_double(Site,
                    name_and_code: 'First Road (F34)',
                    address_line1: 'Fountain Street',
                    address_line2: 'Morley',
                    address_line3: 'Leeds',
                    postcode: 'LS27 OPD')
  end

  let(:provider) do
    instance_double(Provider,
                    name_and_code: 'Best Training (B54)')
  end

  let(:accredited_provider) do
    instance_double(Provider,
                    name_and_code: 'Accredit Now (A78)')
  end

  let(:course) do
    instance_double(Course,
                    name_and_code: 'Geograpghy (H234)',
                    recruitment_cycle_year: 2020,
                    accredited_provider: nil,
                    funding_type: 'fee')
  end

  let(:course_with_accredited_body) do
    instance_double(Course,
                    name_and_code: 'Geograpghy (H234)',
                    recruitment_cycle_year: 2020,
                    accredited_provider: accredited_provider,
                    funding_type: 'fee')
  end

  let(:application_choice) do
    instance_double(ApplicationChoice,
                    course_option: course_option,
                    provider: provider,
                    course: course,
                    site: site)
  end

  let(:application_choice_with_accredited_body) do
    instance_double(ApplicationChoice,
                    course_option: course_option,
                    provider: provider,
                    course: course_with_accredited_body,
                    site: site)
  end

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
    expect(render_text).to include('Best Training (B54)')
  end

  context 'when an accredited body is present' do
    it 'renders the accredited body name and code when it is present' do
      render = render_inline(described_class.new(application_choice: application_choice_with_accredited_body))

      render_text = row_text_selector(:accredited_body, render)

      expect(render_text).to include('Accredited body')
      expect(render_text).to include('Accredit Now (A78)')
    end
  end

  context 'when an accredited body is not present' do
    it 'renders the provider name and code in place of the accredited body name and code' do
      render_text = row_text_selector(:accredited_body, render)

      expect(render_text).to include('Accredited body')
      expect(render_text).to include('Best Training (B54)')
    end
  end

  it 'renders the course name and code' do
    render_text = row_text_selector(:course, render)

    expect(render_text).to include('Course')
    expect(render_text).to include('Geograpghy (H234)')
  end

  it 'renders the recruitment cycle year' do
    render_text = row_text_selector(:cycle, render)

    expect(render_text).to include('Cycle')
    expect(render_text).to include('2020')
  end

  it 'renders the preferred location' do
    render_text = row_text_selector(:location, render)

    expect(render_text).to include('Preferred location')
    expect(render_text).to include('First Road (F34)')
    expect(render_text).to include('Fountain Street, Morley, Leeds')
    expect(render_text).to include('LS27 OPD')
  end

  it 'renders the study mode' do
    render_text = row_text_selector(:full_or_part_time, render)

    expect(render_text).to include('Full or part time')
    expect(render_text).to include('Full time')
  end

  it 'renders financing funding type of a course' do
    render_text = row_text_selector(:funding_type, render)

    expect(render_text).to include('Funding type')
    expect(render_text).to include('Fee paying')
  end
end
