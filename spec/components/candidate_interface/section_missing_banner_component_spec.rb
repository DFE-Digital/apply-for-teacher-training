require 'rails_helper'

RSpec.describe CandidateInterface::SectionMissingBannerComponent do
  it 'renders a section missing banner component' do
    result = render_inline(described_class.new(section: 'degrees', section_path: '#'))
    expect(result.css('.app-banner__message .govuk-body').text).to include('Degree(s) section not marked as completed')
    expect(result.css('.app-banner__message .govuk-link')).to be_present
    expect(result.css('.app-banner__message .govuk-link').text).to include('Enter your degree(s)')
  end

  it 'renders custom link text if given' do
    result = render_inline(described_class.new(section: 'degrees', section_path: '#', link_text: 'Click here to win'))
    expect(result.css('.app-banner__message .govuk-body').text).to include('Degree(s) section not marked as completed')
    expect(result.css('.app-banner__message .govuk-link')).to be_present
    expect(result.css('.app-banner__message .govuk-link').text).to include('Click here to win')
  end
end
