require 'rails_helper'

RSpec.describe ProviderInterface::ProviderApplicationsPageState do
  describe '#sort_order' do
    it 'calculates correct sort order when params sort order is asc' do
      params = { sort_order: 'asc' }
      state = described_class.new(params: params)

      expect(state.sort_order).to eq('asc')
    end

    it 'calculates correct sort order when params sort order is desc' do
      params = { sort_order: 'desc' }
      state = described_class.new(params: params)

      expect(state.sort_order).to eq('desc')
    end

    it 'defaults to sort desc if not asc' do
      params = { sort_order: 'these are not the droids you are looking for' }
      state = described_class.new(params: params)

      expect(state.sort_order).to eq('desc')
    end
  end

  describe '#sort_by' do
    it 'defaults to last-updated if not present' do
      params = {}
      state = described_class.new(params: params)

      expect(state.sort_by).to eq('last-updated')
    end

    it 'returns value if present' do
      params = { sort_by: 'name' }
      state = described_class.new(params: params)

      expect(state.sort_by).to eq('name')
    end
  end

  describe '#filter_visible' do
    it 'defaults to true if not present' do
      params = {}
      state = described_class.new(params: params)

      expect(state.filter_visible).to eq('true')
    end

    it 'returns value if present' do
      params = { 'filter_visible' => 'false' }

      state = described_class.new(params: params)

      expect(state.filter_visible).to eq('false')
    end
  end

  describe '#ordering_arguments' do
    it 'returns nil if "course", "updated", or "name" not presend as sort_by values' do
      params = { sort_by: 'something completely different' }
      state = described_class.new(params: params)

      expect(state.ordering_arguments).to eq(nil)
    end

    it 'returns a sort order hash when user is sorting by course' do
      params = { sort_by: 'course', sort_order: 'desc' }
      state = described_class.new(params: params)

      expect(state.ordering_arguments.keys.first).to eq('courses.name')
      expect(state.ordering_arguments['courses.name']).to eq('desc')
    end

    it 'returns a sort order hash when user is sorting by last-updated' do
      params = { sort_by: 'last-updated', sort_order: 'asc' }
      state = described_class.new(params: params)

      expect(state.ordering_arguments.keys.first).to eq('application_choices.updated_at')
      expect(state.ordering_arguments['application_choices.updated_at']).to eq('asc')
    end

    it 'returns a sort order hash when user is sorting by name' do
      params = { sort_by: 'name', sort_order: 'asc' }
      state = described_class.new(params: params)

      expect(state.ordering_arguments.keys.first).to eq('last_name')
      expect(state.ordering_arguments.keys.last).to eq('first_name')
      expect(state.ordering_arguments['last_name']).to eq('asc')
      expect(state.ordering_arguments['first_name']).to eq('asc')
    end
  end

  describe '#filter_options' do
    it 'returns an array of filter options if params[filters][status] is present' do
      params = { 'filter' => {"status"=> {"recruited"=>"on", "declined"=>"on", "awaiting_provider_decision"=>"on", "offer"=>"on"}} }
      state = described_class.new(params: params)

      expect(state.filter_options).to eq(%W(recruited declined awaiting_provider_decision offer))
    end

    it 'if filter param does not exits it returns an empty array' do
      params = { }
      state = described_class.new(params: params)

      expect(state.filter_options).to eq([])
    end
  end
end

