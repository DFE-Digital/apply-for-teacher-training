require 'rails_helper'

RSpec.describe RestructuredWorkHistory::GapComponent do
  let(:break_period) { double }

  before do
    allow(break_period).to receive_messages(length: 3, start_date: Date.new(2020, 1, 1), end_date: Date.new(2020, 5, 1))
  end

  it 'renders the component with a link to explain break' do
    result = render_inline(described_class.new(break_period:))

    expect(result.text).to include('Add another job between January 2020 and May 2020')
    expect(result.css('a').last.attributes['href'].value).to eq '/candidate/application/restructured-work-history/explain-break/new?end_date=2020-05-01&start_date=2020-01-01'
  end

  it 'renders the component with a link to add another job' do
    result = render_inline(described_class.new(break_period:))

    expect(result.text).to include('Add another job between January 2020 and May 2020')
    expect(result.css('a').first.attributes['href'].value).to eq '/candidate/application/restructured-work-history/new'
  end

  it 'renders the component with the break length' do
    result = render_inline(described_class.new(break_period:))

    expect(result.text).to include('You have a break in your work history (3 months)')
  end
end
