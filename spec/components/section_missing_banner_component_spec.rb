require 'rails_helper'

RSpec.describe SectionMissingBannerComponent do
  it 'renders a section missing banner component' do
    result = render_inline(SectionMissingBannerComponent, section: 'degrees', section_path: '#')
    expect(result.css('.app-banner__message .govuk-body').text).to include('Degree(s) are not marked as completed')
    expect(result.css('.app-banner__message .govuk-link')).to be_present
  end
end
