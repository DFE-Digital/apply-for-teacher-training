require 'rails_helper'

RSpec.describe TaskListItemComponent do
  def render_component(completed:, custom_status: nil, custom_color: nil)
    render_inline(TaskListItemComponent.new(text: 'Personal details', path: '/personal-details', completed: completed, custom_status: custom_status, custom_color: custom_color))
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

  context 'when given a custom status' do
    it 'renders with a custom status badge' do
      result = render_component(completed: false, custom_status: 'In progress')
      expect(result.css('#personal-details-badge-id').text).to include('In progress')
      expect(result.css('#personal-details-badge-id').first[:class]).to include('govuk-tag--purple')
    end

    it 'prioritises the custom status over the completed status' do
      result = render_component(completed: true, custom_status: 'In progress')
      expect(result.css('#personal-details-badge-id').text).to include('In progress')
      expect(result.css('#personal-details-badge-id').first[:class]).to include('govuk-tag--purple')
    end

    it 'renders custom colors' do
      result = render_component(completed: false, custom_status: 'In progress', custom_color: 'pink')
      expect(result.css('#personal-details-badge-id').text).to include('In progress')
      expect(result.css('#personal-details-badge-id').first[:class]).to include('govuk-tag--pink')
    end
  end
end
