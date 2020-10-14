require 'rails_helper'

RSpec.describe TaskListItemReferencesComponent do
  def render_component(references: [])
    render_inline(described_class.new(references: references))
  end

  it 'renders an empty list when there are no references' do
    result = render_component
    expect(result.css('ul').text.strip).to eq ''
  end

  it 'renders an unrequested reference correctly' do
    reference = build(:reference, name: 'Terence Terry', feedback_status: 'not_requested_yet')
    result = render_component(references: [reference])
    expect(result.css('ul').text).to include('Terence Terry: Not requested yet')
  end
end
