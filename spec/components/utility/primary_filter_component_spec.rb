require 'rails_helper'

RSpec.describe PrimaryFilterComponent do
  describe '#render?' do
    context 'when a primary filter is not present' do
      it 'does not render the component' do
        component = described_class.new(filters: [], primary_filter: nil)
        render_inline(component)
        expect(page).to have_no_css('app-search')
      end
    end

    context 'when a primary filter is present' do
      it 'renders the component' do
        component = described_class.new(filters: [], primary_filter: { name: 'filter' })
        render_inline(component)
        expect(page).to have_no_css('app-search')
      end
    end
  end

  describe '#filters_to_params' do
    let(:component) do
      described_class.new(filters:, primary_filter: { name: 'filter' })
    end

    context 'when the filter element type is location_search' do
      let(:filters) do
        [{ name: 'Location', type: :location_search, original_location: 'London' }]
      end

      it 'returns a hash with the original_location key and value' do
        expect(component.filters_to_params(filters)).to eq({ original_location: 'London' })
      end
    end

    context 'when the filter element type is search' do
      let(:filters) do
        [{ name: 'Search', type: :search, value: 'Name' }]
      end

      it 'returns a hash containing the filters name and value' do
        expect(component.filters_to_params(filters)).to eq({ 'Search' => 'Name' })
      end
    end

    context 'when the filter elements are checkboxes or checkbox_filter' do
      let(:filters) do
        [
          { name: 'Filter', type: :checkboxes, options: [
            { checked: true, value: 'Yes' }, { checked: false, value: 'No' }
          ] },
        ]
      end

      it 'returns a hash' do
        expect(component.filters_to_params(filters)).to eq('Filter' => ['Yes'])
      end
    end
  end

  describe '#remove_search_tag_link' do
    let(:component) do
      described_class.new(filters:, primary_filter: { name: 'filter' })
    end
    let(:filters) do
      [
        { name: 'Search', type: :search, value: 'Name' },
        { name: 'Location', type: :location_search, original_location: 'London' },
      ]
    end

    it 'generates a link query with the selected filter removed' do
      expect(component.remove_search_tag_link('Search')).to eq(
        '?original_location=London&remove=true',
      )
    end
  end
end
