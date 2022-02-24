require 'rails_helper'

RSpec.describe CandidateInterface::InvalidSectionComponent do
  it 'renders a section invalid banner component' do
    result = render_inline(described_class.new(section: 'degrees', section_path: '#'))
    expect(result.css('.app-inset-text__title').text).to include('Degree not complete')
    expect(result.css('.app-inset-text--important .govuk-link')).to be_present
    expect(result.css('.app-inset-text--important .govuk-link').text).to include('Complete degrees section')
  end

  it 'renders custom link text if given' do
    result = render_inline(described_class.new(section: 'degrees', section_path: '#', link_text: 'Click here to win'))
    expect(result.css('.app-inset-text__title').text).to include('Degree not complete')
    expect(result.css('.app-inset-text--important .govuk-link')).to be_present
    expect(result.css('.app-inset-text--important .govuk-link').text).to include('Click here to win')
  end
end
