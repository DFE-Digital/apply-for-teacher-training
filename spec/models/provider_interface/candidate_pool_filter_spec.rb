require 'rails_helper'

RSpec.describe ProviderInterface::CandidatePoolFilter do
  include Rails.application.routes.url_helpers

  let(:client) { instance_double(GoogleMapsAPI::Client) }
  let(:api_response) { [{ name: 'BN1 1AA', place_id: }] }
  let(:place_id) { 'test_id' }

  before do
    allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:autocomplete).and_return(api_response)
  end

  describe '#applied_filters' do
    it 'returns the applied filters' do
      filter_params = {
        'location' => 'Manchester',
        'visa_sponsorship' => ['required'],
      }
      current_provider_user = create(:provider_user)
      filter = described_class.new(
        filter_params:,
        current_provider_user:,
        remove_filter: {},
      )
      filter.save

      expect(filter.applied_filters).to eq(
        {
          location: 'Manchester',
          visa_sponsorship: ['required'],
          origin: [53.4706519, -2.2954452],
        }.with_indifferent_access,
      )
    end

    context 'when location is not complete' do
      let(:place_id) { 'm4_place_id' }

      it 'returns the applied filters with the completed location' do
        filter_params = {
          'location' => 'm4',
          'visa_sponsorship' => ['required'],
        }
        current_provider_user = create(:provider_user)
        filter = described_class.new(
          filter_params:,
          current_provider_user:,
          remove_filter: {},
        )
        filter.save

        expect(filter.applied_filters).to eq(
          {
            location: 'M4 Manchester',
            origin: [53.4874112, - 2.2274845],
            visa_sponsorship: ['required'],
          }.with_indifferent_access,
        )
      end
    end

    context 'when location is invalid' do
      it 'returns the applied filters when location is invalid' do
        allow(client).to receive(:autocomplete).and_return([])

        filter_params = {
          'original_location' => 'wrong location',
          'visa_sponsorship' => ['required'],
        }
        current_provider_user = create(:provider_user)
        filter = described_class.new(filter_params:, current_provider_user:)

        expect(filter.applied_filters).to eq(
          {
            original_location: 'wrong location',
            visa_sponsorship: ['required'],
          }.with_indifferent_access,
        )
      end
    end
  end

  describe '#applied_location_search?' do
    it 'returns true if location search is applied' do
      filter_params = { 'original_location' => 'Manchester' }
      current_provider_user = create(:provider_user)
      filter = described_class.new(filter_params:, current_provider_user:)
      filter.applied_filters

      expect(filter.applied_location_search?).to be_truthy
    end

    it 'returns false if location search is applied' do
      current_provider_user = create(:provider_user)
      filter = described_class.new(filter_params: {}, current_provider_user:)

      expect(filter.applied_location_search?).to be_falsey
    end
  end
end
