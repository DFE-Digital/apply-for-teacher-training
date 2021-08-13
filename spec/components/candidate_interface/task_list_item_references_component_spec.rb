require 'rails_helper'

RSpec.describe CandidateInterface::TaskListItemReferencesComponent do
  def render_component(references: [])
    render_inline(described_class.new(references: references))
  end

  it 'renders an empty list when there are no references' do
    result = render_component
    expect(result.css('ul').text.strip).to eq ''
  end

  it 'renders an unrequested reference correctly' do
    reference = build(:reference, name: 'Billy Williams', feedback_status: 'not_requested_yet')
    result = render_component(references: [reference])
    expect(result.css('ul').text).to include('Billy Williams: Not sent yet')
    expect(result.css('li span.app-status-indicator--grey')).to be_present
  end

  it 'renders a provided reference correctly' do
    reference = build(:reference, name: 'Millie Milton', feedback_status: 'feedback_provided')
    result = render_component(references: [reference])
    expect(result.css('ul').text).to include('Millie Milton: Reference received')
    expect(result.css('li span.app-status-indicator--green')).to be_present
  end
end
