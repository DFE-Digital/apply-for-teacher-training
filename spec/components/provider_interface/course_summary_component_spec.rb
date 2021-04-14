require 'rails_helper'

RSpec.describe ProviderInterface::CourseSummaryComponent do
  let(:provider) do
    build(:provider, name: 'Best Training')
  end

  let(:site) do
    build(
      :site,
      provider: provider,
      name: 'First Road',
      address_line1: 'Fountain Street',
      address_line2: 'Morley',
      address_line3: 'Leeds',
      postcode: 'LS27 OPD',
    )
  end

  let(:course) do
    build(
      :course,
      name: 'Geograpghy',
      code: 'H234',
      provider: provider,
    )
  end

  let(:course_option) do
    build(
      :course_option,
      :full_time,
      site: site,
      course: course,
    )
  end

  let(:render) { render_inline(described_class.new(course_option: course_option)) }

  def row_text_selector(row_name, render)
    rows = {
      provider: 0,
      course: 1,
      location: 2,
      full_or_part_time: 3,
      accredited_body: 4,
    }

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  it 'renders the provider name' do
    render_text = row_text_selector(:provider, render)

    expect(render_text).to include('Provider')
    expect(render_text).to include('Best Training')
  end

  it 'renders the course name and code' do
    render_text = row_text_selector(:course, render)

    expect(render_text).to include('Course')
    expect(render_text).to include('Geograpghy (H234)')
  end

  it 'renders the location' do
    render_text = row_text_selector(:location, render)

    expect(render_text).to include('Location')
    expect(render_text).to include('First Road, Fountain Street, Morley, Leeds, LS27 OPD')
  end

  it 'renders the study mode' do
    render_text = row_text_selector(:full_or_part_time, render)

    expect(render_text).to include('Full time or part time')
    expect(render_text).to include('Full time')
  end

  context 'renders the accredited body' do
    let(:course) { build(:course, :with_accredited_provider) }

    it 'when one is set' do
      render_text = row_text_selector(:accredited_body, render)

      expect(render_text).to include('Accredited body')
      expect(render_text).to include(course.accredited_provider.name_and_code)
    end
  end
end
