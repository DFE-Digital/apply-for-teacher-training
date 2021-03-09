require 'rails_helper'

RSpec.describe ProviderInterface::OfferSummaryComponent do
  let(:application_choice) { build_stubbed(:application_choice) }
  let(:course_option) { build_stubbed(:course_option) }
  let(:render) do
    render_inline(described_class.new(application_choice: application_choice,
                                      course_option: course_option,
                                      conditions: ['condition 1', 'condition 2']))
  end

  def row_text_selector(row_name, render)
    rows = {
      provider: 0,
      course: 1,
      location: 2,
      full_or_part_time: 3,
    }

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  it 'renders the new course option details' do
    expect(row_text_selector(:provider, render)).to include(course_option.provider.name)
    expect(row_text_selector(:course, render)).to include(course_option.course.name_and_code)
    expect(row_text_selector(:location, render)).to include(course_option.site.name_and_address)
    expect(row_text_selector(:full_or_part_time, render)).to include(course_option.study_mode.humanize)
  end

  it 'renders conditions' do
    expect(render.css('.conditions').text).to include('condition 1')
    expect(render.css('.conditions').text).to include('condition 2')
  end
end
