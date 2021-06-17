require 'rails_helper'

RSpec.describe ProviderInterface::DeferredOfferDetailsComponent do
  let(:application_choice) { instance_double(ApplicationChoice, offer: nil) }
  let(:provider) { build(:provider, name: 'Best Training') }
  let(:course_option) { build(:course_option) }

  let(:render) { render_inline(described_class.new(application_choice: application_choice, course_option: course_option)) }

  def row_text_selector(row_name, render)
    rows = {
      provider: 0,
      course: 1,
      full_or_part_time: 2,
      location: 3,
    }

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  it 'renders the provider name' do
    render_text = row_text_selector(:provider, render)

    expect(render_text).to include('Provider')
    expect(render_text).to include(course_option.course.provider.name)
  end

  it 'renders the course name and code' do
    render_text = row_text_selector(:course, render)

    expect(render_text).to include('Course')
    expect(render_text).to include(course_option.course.name_and_code)
  end

  it 'renders the study mode' do
    render_text = row_text_selector(:full_or_part_time, render)

    expect(render_text).to include('Full time or part time')
    expect(render_text).to include(course_option.study_mode.humanize)
  end

  it 'renders the location' do
    render_text = row_text_selector(:location, render)

    expect(render_text).to include('Location')
    expect(render_text).to include(course_option.site.name_and_address)
  end
end
