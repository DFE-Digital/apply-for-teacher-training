require 'rails_helper'

RSpec.describe CandidateInterface::LocationPreferencesForm, type: :model do
  subject(:form) do
    described_class.new(preference:, location_preference:, params:)
  end

  let(:preference) { create(:candidate_preference) }
  let(:location_preference) { nil }
  let(:params) { { name: 'BN1 1AA', within: 20 } }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:within) }
    it { is_expected.to validate_presence_of(:name) }

    context 'when location name is invalid' do
      it 'adds location preferences blank error' do
        allow(Geocoder).to receive(:search).and_return([])

        expect(form.valid?).to be_falsey
        expect(form.errors[:base]).to eq(['Enter a real city, town or postcode'])
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
          latitude: 51.4524877,
          longitude: -0.1204749,
        )
      end
    end

    context 'when updating a location_preference' do
      let(:location_preference) { create(:candidate_location_preference) }

      it 'updates a preference to opt out and publishes the preference' do
        expect { form.save }.to change(location_preference, :name).from(location_preference.name).to('BN1 1AA')
          .and change(location_preference, :within).from(location_preference.within).to(20)
          .and change(location_preference, :latitude).from(location_preference.latitude).to(51.4524877)
          .and change(location_preference, :longitude).from(location_preference.longitude).to(-0.1204749)
      end
    end
  end
end
