require 'rails_helper'

RSpec.describe SummaryCardHeaderComponent do
  it 'renders a summary card header component with a title only' do
    result = render_inline(described_class.new(title: 'Lando Calrissian'))
    expect(result.css('.app-summary-card__title').text).to include('Lando Calrissian')
    expect(result.css('.app-summary-card__meta').text).not_to be_present
    expect(result.css('.app-icon').text).not_to be_present
  end

  it 'renders a summary card header component with a custom heading level' do
    result = render_inline(described_class.new(title: 'Lando Calrissian', heading_level: 6))
    expect(result.css('h6.app-summary-card__title')).to be_present
  end
end
