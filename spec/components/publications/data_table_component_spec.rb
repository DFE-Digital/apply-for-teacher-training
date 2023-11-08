require 'rails_helper'

RSpec.describe Publications::DataTableComponent do
  let(:component) { described_class.new(caption:, title:, data:) }
  let(:caption) { 'Table with data' }
  let(:title) { 'Age' }
  let(:data) do
    {
      submitted: [
        { title: '18 - 21', this_cycle: 22, last_cycle: 44 },
      ],
      with_offers: [
        { title: '18 - 21', this_cycle: 55, last_cycle: 88 },
      ],
    }
  end

  it 'renders the table caption' do
    result = render_inline(component)
    expect(result).to have_css('.govuk-heading-m', text: caption)
  end

  it 'renders the "submitted" table' do
    result = render_inline(component)
    expect(result).to have_css('#age-submitted')
  end

  it 'does not render the "with-offers" table' do
    result = render_inline(component)
    expect(result).not_to have_css('#age-with_offers')
  end

  it 'shows the right data in the right cell' do
    result = render_inline(component)
    submitted_this_cycle_value = result.css('#age-submitted tbody td:first-of-type').text
    actual = data[:submitted].first[:this_cycle].to_s

    expect(submitted_this_cycle_value).to eq(actual)
  end
end
