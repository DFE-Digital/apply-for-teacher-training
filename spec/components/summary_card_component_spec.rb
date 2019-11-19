require 'rails_helper'

RSpec.describe SummaryCardComponent do
  it 'renders a summary list component for rows' do
    rows = [
      key: 'Name:',
      value: 'Lando Calrissian'
    ]
    result = render_inline(SummaryCardComponent, rows: rows)

    expect(result.css).to include('.govuk-summary-list')
    expect(result.css('.govuk-summary-list__value').text).to include('Lando Calrissian')
  end
end
