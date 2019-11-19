require 'rails_helper'

RSpec.describe SummaryCardComponent do
  let(:rows) do
    [
      key: 'Character',
      value: 'Lando Calrissian',
    ]
  end

  it 'renders a summary list component for rows' do
    result = render_inline(SummaryCardComponent, rows: rows)
    expect(result.css('.govuk-summary-list__value').text).to include('Lando Calrissian')
    expect(result.css('.govuk-summary-list__key').text).to include('Character')
  end

  it 'renders content at the top of a summary card' do
    result = render_inline(SummaryCardComponent, rows: rows) { 'In a galaxy' }
    expect(result.text).to include('In a galaxy')
  end
end
