require 'rails_helper'

RSpec.describe CandidateInterface::ReferenceStatusesComponent do
  def render_component(references:)
    render_inline(described_class.new(references: references))
  end

  it 'does not render when there are no references' do
    result = render_component(references: [])

    expect(result.text).to be_blank
  end

  it 'renders an unrequested reference correctly' do
    reference = create(:reference, name: 'Billy Williams', feedback_status: 'not_requested_yet')
    result = render_component(references: [reference])
    expect(result.css('ul').text).to include('Billy Williams: Not sent yet')
    expect(result.css('li span.app-status-indicator--grey')).to be_present
    expect(result.css('li span.app-status-indicator--filled')).to be_present
  end

  it 'renders a provided reference correctly' do
    reference = create(:reference, name: 'Millie Milton', feedback_status: 'feedback_provided')
    result = render_component(references: [reference])
    expect(result.css('ul').text).to include('Millie Milton: Reference received')
    expect(result.css('li span.app-status-indicator--green')).to be_present
    expect(result.css('li span.app-status-indicator--filled')).not_to be_present
  end

  it 'renders a selected reference correctly' do
    reference = create(:selected_reference, name: 'Millie Milton')
    result = render_component(references: [reference])
    expect(result.css('ul').text).to include('Millie Milton: Reference selected')
    expect(result.css('li span.app-status-indicator--green')).to be_present
    expect(result.css('li span.app-status-indicator--filled')).to be_present
  end
end
