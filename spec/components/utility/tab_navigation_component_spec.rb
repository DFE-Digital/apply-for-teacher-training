require 'rails_helper'

RSpec.describe TabNavigationComponent do
  let(:items) do
    [{ name: 'Application', url: '#', current: true },
     { name: 'Notes', url: '#' },
     { name: 'Timeline', url: '#' }]
  end

  context 'nav tabs appearing as selected' do
    it 'when the item is "current" then that tab is selected' do
      result = render_inline(described_class.new(items: items))

      expect(result.css('.app-tab-navigation__link[aria-current="page"]').text).to include('Application')
    end
  end

  context 'rendering tabs' do
    it 'renders all of the nav tabs specified in the items hash passed to it' do
      result = render_inline(described_class.new(items: items))

      expect(result.text).to include('Application')
      expect(result.text).to include('Notes')
      expect(result.text).to include('Timeline')
    end
  end
end
