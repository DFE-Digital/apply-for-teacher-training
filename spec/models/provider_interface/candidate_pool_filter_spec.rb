require 'rails_helper'

RSpec.describe ProviderInterface::CandidatePoolFilter do
  include Rails.application.routes.url_helpers

  let(:client) { instance_double(GoogleMapsAPI::Client) }
  let(:api_response) { [{ name: location_name, place_id: }] }
  let(:location_name) { 'Manchester' }
  let(:place_id) { 'test_id' }

  before do
    allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:autocomplete).and_return(api_response)
  end

  describe 'validations' do
    context 'when location is invalid' do
      let(:place_id) { 'wrong_location' }

      it 'is invalid if the location is invalid' do
        filter_params = {
          location: 'wrong_location',
          visa_sponsorship: ['required'],
        }
        current_provider_user = create(:provider_user)
        filter = described_class.new(
          filter_params:,
          current_provider_user:,
          remove_filter: {},
        )

        expect(filter.valid?).to be false
        expect(filter.errors[:location]).to eq(
          ['Town, city or postcode must be in the United Kingdom'],
        )
      end
    end

    context 'when location is valid' do
      it 'is valid if the location is valid' do
        filter_params = {
          location: 'Manchester',
          visa_sponsorship: ['required'],
        }
        current_provider_user = create(:provider_user)
        filter = described_class.new(
          filter_params:,
          current_provider_user:,
          remove_filter: {},
        )

        expect(filter.valid?).to be true
      end
    end
  end

  describe '#applied_filters' do
    it 'returns the applied filters' do
      filter_params = {
        location: 'Manchester',
        visa_sponsorship: ['required'],
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

    context 'when current_provider_user has filters saved' do
      it 'returns the current_provider_user filters' do
        current_provider_user = create(
          :provider_user,
          find_a_candidate_filters: {
            location: 'Manchester',
            visa_sponsorship: ['required'],
          },
        )

        filter = described_class.new(
          filter_params: {},
          current_provider_user:,
          remove_filter: {},
        )

        expect(filter.applied_filters).to eq(
          {
            location: 'Manchester',
            visa_sponsorship: ['required'],
            origin: [53.4706519, -2.2954452],
          }.with_indifferent_access,
        )
      end
    end

    context 'when location is not complete' do
      let(:location_name) { 'M4 Manchester' }
      let(:place_id) { 'm4_place_id' }

      it 'returns the applied filters with the completed location' do
        filter_params = {
          location: 'm4',
          visa_sponsorship: ['required'],
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

        filter_params = { location: 'wrong location' }
        current_provider_user = create(:provider_user)
        filter = described_class.new(
          filter_params:,
          current_provider_user:,
          remove_filter: {},
        )
        filter.save

        expect(filter.applied_filters).to eq(
          {}.with_indifferent_access,
        )
      end
    end
  end

  describe '#save' do
    context 'When valid' do
      it 'saves the filters on the current_provider_user' do
        filter_params = {
          location: 'Manchester',
          visa_sponsorship: ['required'],
        }
        current_provider_user = create(:provider_user)
        filter = described_class.new(
          filter_params:,
          current_provider_user:,
          remove_filter: {},
        )
        expect { filter.save }.to change {
          current_provider_user.find_a_candidate_filters
        }.from({}).to(filter_params.with_indifferent_access)
      end
    end

    context 'When invalid' do
      let(:place_id) { 'wrong_location' }

      it 'does not save the filters on the current_provider_user' do
        filter_params = {
          location: 'wrong_location',
          visa_sponsorship: ['required'],
        }
        current_provider_user = create(:provider_user)
        filter = described_class.new(
          filter_params:,
          current_provider_user:,
          remove_filter: {},
        )

        expect { filter.save }.not_to change {
          current_provider_user.find_a_candidate_filters
        }.from({})
      end
    end

    context 'When filters are cleared' do
      it 'saves an empty hash on the current_provider_user' do
        filters = { 'location' => 'Manchester' }
        current_provider_user = create(
          :provider_user,
          find_a_candidate_filters: filters,
        )
        filter = described_class.new(
          filter_params: {},
          current_provider_user:,
          remove_filter: { remove_filter: true },
        )

        expect { filter.save }.to change {
          current_provider_user.find_a_candidate_filters
        }.from(filters).to({})
      end
    end
  end

  describe '#applied_location_search?' do
    it 'returns true if location search is applied' do
      filter_params = { location: 'Manchester' }
      current_provider_user = create(:provider_user)
      filter = described_class.new(
        filter_params:,
        current_provider_user:,
        remove_filter: {},
      )
      filter.save
      filter.applied_filters

      expect(filter.applied_location_search?).to be_truthy
    end

    it 'returns false if location search is applied' do
      current_provider_user = create(:provider_user)
      filter = described_class.new(
        filter_params: {},
        current_provider_user:,
        remove_filter: {},
      )
      filter.save
      filter.applied_filters

      expect(filter.applied_location_search?).to be_falsey
    end
  end
end
