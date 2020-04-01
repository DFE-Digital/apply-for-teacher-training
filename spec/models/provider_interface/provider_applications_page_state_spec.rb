require 'rails_helper'

RSpec.describe ProviderInterface::ProviderApplicationsPageState do
  let(:correct_available_filters) {
    [
      {
        heading: "candidate's name",
        input_config: [
          {
            type: 'search',
            text: '',
            name: 'candidates_name',
          },
        ],
      },
      {
        heading: 'status',
        input_config: [
          {
            type: 'checkbox',
            text: 'New',
            name: 'awaiting_provider_decision',
          },
          {
            type: 'checkbox',
            text: 'Offered',
            name: 'offer',
          },
          {
            type: 'checkbox',
            text: 'Rejected',
            name: 'rejected',
          },
          {
            type: 'checkbox',
            text: 'Accepted',
            name: 'pending_conditions',
          },
          {
            type: 'checkbox',
            text: 'Declined',
            name: 'declined',
          },
          {
            type: 'checkbox',
            text: 'Application withdrawn',
            name: 'withdrawn',
          },
          {
            type: 'checkbox',
            text: 'Withdrawn by us',
            name: 'offer_withdrawn',
          },
          {
            type: 'checkbox',
            text: 'Conditions met',
            name: 'recruited',
          },
          {
            type: 'checkbox',
            text: 'Enrolled',
            name: 'enrolled',
          },
        ],
      },
      {
        heading: 'provider',
        input_config: [
          {
            type: 'checkbox',
            text: 'Gorse SCITT',
            name: '1',
          },
          {
            type: 'checkbox',
            text: 'University of Chichester',
            name: '4',
          },
        ],
      },
      {
        heading: 'accredited_provider',
        input_config: [
          {
            type: 'checkbox',
            text: 'University of West England',
            name: '5',
          },
          {
            type: 'checkbox',
            text: 'University of East England',
            name: '6',
          },
        ],
      },
    ]
  }
  let(:provider_user) { instance_double(ProviderUser) }

  before do
    @provider_service = instance_double(ProviderInterface::ProviderOptionsService)
    allow(ProviderInterface::ProviderOptionsService).to receive(:new).and_return(@provider_service)
    allow(@provider_service).to receive(:accredited_providers).and_return([
      instance_double(Provider, id: '5', name: 'University of West England'),
      instance_double(Provider, id: '6', name: 'University of East England'),
    ])
    allow(@provider_service).to receive(:providers).and_return([
      instance_double(Provider, id: '1', name: 'Gorse SCITT'),
      instance_double(Provider, id: '4', name: 'University of Chichester'),
    ])
  end

  describe '#sort_order' do
    it 'calculates correct sort order when params sort order is asc' do
      params = ActionController::Parameters.new(sort_order: 'asc')
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.sort_order).to eq('asc')
    end

    it 'calculates correct sort order when params sort order is desc' do
      params = ActionController::Parameters.new(sort_order: 'desc')
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.sort_order).to eq('desc')
    end

    it 'defaults to sort desc if not asc' do
      params = ActionController::Parameters.new(sort_order: 'these are not the droids you\re looking for')
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.sort_order).to eq('desc')
    end
  end

  describe '#sort_by' do
    it 'defaults to last-updated if not present' do
      params = ActionController::Parameters.new
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.sort_by).to eq('last-updated')
    end

    it 'returns value if present' do
      params = ActionController::Parameters.new(sort_by: 'name')
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.sort_by).to eq('name')
    end
  end

  describe '#filter_visible' do
    it 'defaults to true if not present' do
      params = ActionController::Parameters.new
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.filter_visible).to eq('true')
    end

    it 'returns value if present' do
      params = ActionController::Parameters.new(filter_visible: 'false')

      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.filter_visible).to eq('false')
    end
  end

  describe '#applications_ordering_query' do
    it 'returns nil if "course", "updated", or "name" not presend as sort_by values' do
      params = ActionController::Parameters.new(sort_by: 'something completely different')
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.applications_ordering_query).to eq(nil)
    end

    it 'returns a sort order hash when user is sorting by course' do
      params = ActionController::Parameters.new(sort_by: 'course', sort_order: 'desc')
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.applications_ordering_query.keys.first).to eq('courses.name')
      expect(state.applications_ordering_query['courses.name']).to eq('desc')
    end

    it 'returns a sort order hash when user is sorting by last-updated' do
      params = ActionController::Parameters.new(sort_by: 'last-updated', sort_order: 'asc')
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.applications_ordering_query.keys.first).to eq('application_choices.updated_at')
      expect(state.applications_ordering_query['application_choices.updated_at']).to eq('asc')
    end

    it 'returns a sort order hash when user is sorting by name' do
      params = ActionController::Parameters.new(sort_by: 'name', sort_order: 'asc')
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.applications_ordering_query.keys.first).to eq('last_name')
      expect(state.applications_ordering_query.keys.last).to eq('first_name')
      expect(state.applications_ordering_query['last_name']).to eq('asc')
      expect(state.applications_ordering_query['first_name']).to eq('asc')
    end
  end

  describe '#available_filters' do
    it 'calculate the correct available_filters' do
      params = ActionController::Parameters.new
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )

      expect(state.available_filters).to eq(correct_available_filters)
    end
  end

  describe '#filter_selections' do
    it 'returns correct hash if values are present' do
      filter_selections = { filter_selections: { 'search' => { 'candidates_name' => 'Ellamae Kunze' },
                                              'status' => { 'recruited' => 'on', 'declined' => 'on' },
                                              'provider' => { '1' => 'on' } } }


      params = ActionController::Parameters.new(filter_selections)
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )
      expect(state.filter_selections).to eq(filter_selections[:filter_selections])
    end

    it 'will return an empty hash if there are no filters selected' do
      filter_selections = { filter_selections: { 'search' => { 'candidates_name' => '' } } }


      params = ActionController::Parameters.new(filter_selections)
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )
      expect(state.filter_selections).to eq({})
    end

    it 'will remove candidates_name field if empty (i.e. "")' do
      filter_selections = { filter_selections: { 'search' => { 'candidates_name' => '' },
                                              'status' => { 'recruited' => 'on', 'declined' => 'on' },
                                              'provider' => { '1' => 'on' } } }


      params = ActionController::Parameters.new(filter_selections)
      state = described_class.new(
        params: params,
        provider_user: provider_user,
      )
      expect(state.filter_selections).to eq(filter_selections[:filter_selections].except('search'))
    end
  end
end
