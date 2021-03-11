require 'rails_helper'

RSpec.describe CandidateInterface::IncompleteSectionComponent do
  it 'renders a section incomplete banner component' do
    result = render_inline(described_class.new(section: 'degrees', section_path: '#'))
    expect(result.css('.app-inset-text__title').text).to include('Degree section not marked as completed')
    expect(result.css('.app-inset-text--important .govuk-link')).to be_present
    expect(result.css('.app-inset-text--important .govuk-link').text).to include('Enter your degrees')
  end

  it 'renders custom link text if given' do
    result = render_inline(described_class.new(section: 'degrees', section_path: '#', link_text: 'Click here to win'))
    expect(result.css('.app-inset-text__title').text).to include('Degree section not marked as completed')
    expect(result.css('.app-inset-text--important .govuk-link')).to be_present
    expect(result.css('.app-inset-text--important .govuk-link').text).to include('Click here to win')
  end
end
