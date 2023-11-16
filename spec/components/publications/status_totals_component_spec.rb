require 'rails_helper'

RSpec.describe Publications::StatusTotalsComponent, type: :component do
  let(:data) { { 'title' => 'Submitted', 'this_cycle' => '11239', 'last_cycle' => '7091' } }
  let(:summary) { 'Candidates who have submitted one or more applications this cycle. Applications which were then withdrawn or deferred are included.' }
  let(:heading_one) { 'This cycle' }
  let(:heading_two) { 'Last cycle' }

  subject(:status_totals_component) do
    described_class.new(
      title: data['title'],
      summary: summary,
      heading_one: heading_one,
      status_total_one: data['this_cycle'],
      heading_two: heading_two,
      status_total_two: data['last_cycle'],
    )
  end

  before do
    @rendered = render_inline(status_totals_component)
  end

  it 'renders the title' do
    expect(@rendered.text).to include(data['title'])
  end

  it 'renders the summary' do
    expect(@rendered.text).to include(summary)
  end

  it 'renders the first number heading' do
    expect(@rendered.text).to include(heading_one)
  end

  it 'renders the first number formatted' do
    expect(@rendered.text).to include('11,239')
  end

  it 'renders the second number heading' do
    expect(@rendered.text).to include(heading_two)
  end

  it 'renders the second number formatted' do
    expect(@rendered.text).to include('7,091')
  end
end
