require 'rails_helper'

RSpec.describe TaskListItemComponent do
  def render_component(completed:)
    render_inline(TaskListItemComponent, text: 'Personal details', path: '/personal-details', completed: completed)
  end

  it 'renders the correct text, href' do
    result = render_component(completed: true)
    expect(result.text).to include('Personal details')
    expect(result.css('a').first.attr(:href)).to eq('/personal-details')
  end

  it 'renders with a completed badge' do
    result = render_component(completed: true)
    expect(result.css('#personal-details-badge-id').text).to include('Completed')
  end

  it 'renders with an incomplete badge' do
    result = render_component(completed: false)
    expect(result.css('#personal-details-badge-id').text).to include('Incomplete')
  end
end
