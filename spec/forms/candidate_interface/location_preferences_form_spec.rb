require 'rails_helper'

RSpec.describe CandidateInterface::LocationPreferencesForm, type: :model do
  subject(:form) do
    described_class.new(preference:, location_preference:, params:)
  end

  let(:preference) { create(:candidate_preference) }
  let(:location_preference) { nil }
  let(:params) { { name: 'BN1 1AA', within: 20 } }

  let(:client) { instance_double(GoogleMapsAPI::Client) }
  let(:api_response) do
    [
      { name: 'BN1 1AA', place_id: 'test_id' },
    ]
  end

  before do
    allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:autocomplete).and_return(api_response)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:within) }
    it { is_expected.to validate_numericality_of(:within).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2) }

    context 'when location name is invalid' do
      it 'adds location preferences blank error' do
        allow(client).to receive(:autocomplete).and_return([])

        expect(form.valid?).to be_falsey
        expect(form.errors[:name]).to eq(['City, town or postcode must be in the United Kingdom'])
      end
    end
  end

  describe '.build_from_preferences' do
    let(:location_preference) { create(:candidate_location_preference) }

    it 'builds the form from a preference' do
      form_object = described_class.build_from_location_preference(
        preference:,
        location_preference:,
      )

      expect(form_object).to have_attributes(
        preference:,
        location_preference:,
        name: location_preference.name,
        within: location_preference.within,
      )
    end
  end

  describe '#save' do
    context 'when creating a location preference' do
      it 'creates a preference and adds location preferences' do
        expect { form.save }.to change(preference.location_preferences, :count).by(1)

        expect(preference.location_preferences.last).to have_attributes(
          name: 'BN1 1AA',
          within: 20,
          latitude: 53.4706519,
          longitude: -2.2954452,
        )
      end
    end

    context 'when updating a location_preference' do
      let(:location_preference) { create(:candidate_location_preference) }

      it 'updates a preference to opt out and publishes the preference' do
        expect { form.save }.to change(location_preference, :name).from(location_preference.name).to('BN1 1AA')
          .and change(location_preference, :within).from(location_preference.within).to(20)
          .and change(location_preference, :latitude).from(location_preference.latitude).to(53.4706519)
          .and change(location_preference, :longitude).from(location_preference.longitude).to(-2.2954452)
      end
    end
  end
end
