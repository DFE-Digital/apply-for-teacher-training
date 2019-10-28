require 'rails_helper'

RSpec.describe SummaryCardComponent do
  it 'renders component with correct structure' do
    rows = [
      key: 'Name:',
      value: 'Lando Calrissian',
      action: 'Name',
      change_path: '/some/url',
    ]
    result = render_inline(SummaryCardComponent, rows: rows)

    expect(result.css('.govuk-summary-list__key').text).to include('Name:')
    expect(result.css('.govuk-summary-list__value').text).to include('Lando Calrissian')
    expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include('/some/url')
    expect(result.css('.govuk-summary-list__actions').text).to include('Change Name')
  end

  it "renders dangerous HTML content when passed in" do
    rows = [
      key: 'Address:',
      DANGEROUS_html_value: 'Whoa Drive,<br>Wewvile<br>London',
      action: 'Name',
      change_path: '/some/url',
    ]
    result = render_inline(SummaryCardComponent, rows: rows)

    expect(result.css('.govuk-summary-list__value').to_html).to include('Whoa Drive,<br>Wewvile<br>London')
  end
end
