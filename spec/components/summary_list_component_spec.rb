require 'rails_helper'

RSpec.describe SummaryListComponent do
  it 'renders component with correct structure' do
    rows = [
      key: 'Name:',
      value: 'Lando Calrissian',
      action: 'Name',
      change_path: '/some/url',
    ]
    result = render_inline(SummaryListComponent, rows: rows)

    expect(result.css('.govuk-summary-list__key').text).to include('Name:')
    expect(result.css('.govuk-summary-list__value').text).to include('Lando Calrissian')
    expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include('/some/url')
    expect(result.css('.govuk-summary-list__actions').text).to include('Change Name')
  end

  it 'renders arrays content when passed in' do
    rows = [
      key: 'Address:',
      value: ['Whoa Drive', 'Wewvile', 'London'],
      action: 'Name',
      change_path: '/some/url',
    ]
    result = render_inline(SummaryListComponent, rows: rows)

    expect(result.css('.govuk-summary-list__value').to_html).to include('Whoa Drive<br>Wewvile<br>London')
  end

  it 'renders component with correct struture using action_path' do
    rows = [
      key: 'Please enter the sound a cat makes',
      value: 'Meow',
      action: 'Enter cat sounds',
      action_path: '/cat/sounds',
    ]
    result = render_inline(SummaryListComponent, rows: rows)

    expect(result.css('.govuk-summary-list__key').text).to include('Please enter the sound a cat makes')
    expect(result.css('.govuk-summary-list__value').text).to include('Meow')
    expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include('/cat/sounds')
    expect(result.css('.govuk-summary-list__actions').text).to include('Enter cat sounds')
  end

  it 'renders HTML in values when safe' do
    rows = [
      key: 'Safe',
      value: '<span class="safe-html">This is safe</span>'.html_safe,
    ]

    result = render_inline(SummaryListComponent, rows: rows)
    expect(result.css('.govuk-summary-list__value > .safe-html').text).to include('This is safe')
  end

  it 'uses simple_format to convert line breaks and strip HTML' do
    rows = [
      key: 'Unsafe',
      value: '<span class="unsafe-html"><script>Unsafe</script></span>',
    ]

    result = render_inline(SummaryListComponent, rows: rows)
    expect(result.css('.govuk-summary-list__value p').to_html).to eq('<p class="govuk-body">Unsafe</p>')
  end
end
