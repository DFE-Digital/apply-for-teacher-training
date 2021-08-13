require 'rails_helper'

RSpec.describe SummaryListComponent do
  it 'renders component with correct structure' do
    rows = [
      key: 'Name:',
      value: 'Lando Calrissian',
      action: 'Name',
      change_path: '/some/url',
    ]
    result = render_inline(described_class.new(rows: rows))

    expect(result.css('.govuk-summary-list__key').text).to include('Name:')
    expect(result.css('.govuk-summary-list__value').text).to include('Lando Calrissian')
    expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include('/some/url')
    expect(result.css('.govuk-summary-list__actions').text).to include('Change Name')
  end

  describe 'array content' do
    it 'renders array content when passed in' do
      rows = [
        key: 'Address:',
        value: ['Whoa Drive', 'Wewvile', 'London'],
        action: 'Name',
        change_path: '/some/url',
      ]
      result = render_inline(described_class.new(rows: rows))

      expect(result.css('.govuk-summary-list__value').to_html).to include('Whoa Drive<br>Wewvile<br>London')
    end

    it 'renders values surrounded by <p> tags if specified for the row' do
      rows = [
        key: 'Address:',
        value: %w[A list of items],
        paragraph_format: true,
      ]
      result = render_inline(described_class.new(rows: rows))

      expect(result.to_html).to include(<<~HTML)
        <p class="govuk-body">A</p>
        <p class="govuk-body">list</p>
        <p class="govuk-body">of</p>
        <p class="govuk-body">items</p>
      HTML
    end

    it 'safely escapes markup when rendering values as <p> tags' do
      rows = [
        key: 'Address:',
        value: ['<script></script>', '<br>'],
        paragraph_format: true,
      ]
      result = render_inline(described_class.new(rows: rows))

      expect(result.to_html).to include(<<~HTML)
        <p class="govuk-body">&lt;script&gt;&lt;/script&gt;</p>
        <p class="govuk-body">&lt;br&gt;</p>
      HTML
    end

    it 'renders values as bullets if specified for the row' do
      rows = [
        key: 'Address:',
        value: %w[A list of items],
        bulleted_format: true,
      ]
      result = render_inline(described_class.new(rows: rows))

      expect(result.to_html).to include(<<~HTML)
        <ul class="govuk-list govuk-list--bullet">
        <li>A</li>
        <li>list</li>
        <li>of</li>
        <li>items</li>
        </ul>
      HTML
    end

    it 'safely escapes markup when rendering values as bullets' do
      rows = [
        key: 'Address:',
        value: ['<script></script>', '<br>'],
        bulleted_format: true,
      ]
      result = render_inline(described_class.new(rows: rows))

      expect(result.to_html).to include(<<~HTML)
        <ul class="govuk-list govuk-list--bullet">
        <li>&lt;script&gt;&lt;/script&gt;</li>
        <li>&lt;br&gt;</li>
        </ul>
      HTML
    end
  end

  it 'renders component with correct struture using action_path' do
    rows = [
      key: 'Please enter the sound a cat makes',
      value: 'Meow',
      action: 'Enter cat sounds',
      action_path: '/cat/sounds',
    ]
    result = render_inline(described_class.new(rows: rows))

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

    result = render_inline(described_class.new(rows: rows))
    expect(result.css('.govuk-summary-list__value > .safe-html').text).to include('This is safe')
  end

  it 'uses simple_format to convert line breaks and strip HTML' do
    rows = [
      key: 'Unsafe',
      value: '<span class="unsafe-html"><script>Unsafe</script></span>',
    ]

    result = render_inline(described_class.new(rows: rows))
    expect(result.css('.govuk-summary-list__value p').to_html).to eq('<p class="govuk-body">Unsafe</p>')
  end

  it 'supports adding data_qa to rows' do
    rows = [{ key: 'Job',
              value: 'Ice cream man',
              data_qa: 'ice-cream-man' }]

    result = render_inline(described_class.new(rows: rows))

    expect(result.css('[data-qa="ice-cream-man"]')).to be_present
  end

  it 'handles rows with multiple actions' do
    rows = [
      { key: 'Role',
        value: 'Chef de partie',
        actions: [
          { verb: 'Change', object: 'role', path: '#change-role' },
          { verb: 'Remove', object: 'this chef', path: '#remove' },
        ] },
    ]

    result = render_inline(described_class.new(rows: rows))

    links = result.css('.govuk-summary-list__actions a')

    expect(links[0].text).to eq 'Change role'
    expect(links[0].attr('href')).to eq '#change-role'

    expect(links[1].text).to eq 'Remove this chef'
    expect(links[1].attr('href')).to eq '#remove'
  end
end
