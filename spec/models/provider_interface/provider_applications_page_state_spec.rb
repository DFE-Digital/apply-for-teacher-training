require 'rails_helper'

RSpec.describe ProviderInterface::ProviderApplicationsPageState do
  let(:correct_available_filters) do
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
            text: 'Accepted',
            name: 'pending_conditions',
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
          {
            type: 'checkbox',
            text: 'Rejected',
            name: 'rejected',
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
            text: 'Conditions not met',
            name: 'conditions_not_met',
          },
          {
            type: 'checkbox',
            text: 'Withdrawn by us',
            name: 'offer_withdrawn',
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
  end
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
