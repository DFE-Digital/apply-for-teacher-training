require 'rails_helper'

RSpec.describe CandidateInterface::Steps::PreferencesWizard::AddLocationPreference, type: :model do
  include DfE::Bigquery::TestHelper

  before do
    stub_bigquery_non_disclosure_trainee_withdrawals_request
    allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:autocomplete).and_return(api_response)
  end

  let(:client) { instance_double(GoogleMapsAPI::Client) }
  let(:api_response) do
    [
      { name: 'BN1 3AA', place_id: },
    ]
  end
  let(:place_id) { 'test_id' }

  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(within: nil, location_name: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:within) }
    it { is_expected.to validate_presence_of(:location_name) }

    context 'when within is equal to or less than 0' do
      it 'is invalid' do
        step = described_class.new(within: -1, location_name: 'London')
        expect(step).not_to be_valid
        expect(step.errors.full_messages).to eq(
          ['Within The location radius must be 0 miles or more'],
        )
      end
    end

    context 'when location_name is less than 1 character long' do
      it 'is invalid' do
        step = described_class.new(within: 10, location_name: 'A')
        expect(step).not_to be_valid
        expect(step.errors.full_messages).to eq(
          ['Location name The city, town or postcode must be 2 characters or more'],
        )
      end
    end

    context 'when location entered is invalid' do
      let(:place_id) { 'wrong_location' }

      it 'is invalid' do
        step = described_class.new(within: 10, location_name: 'London')
        expect(step).not_to be_valid
        expect(step.errors.full_messages).to eq(
          ['Location name City, town or postcode must be in the United Kingdom'],
        )
      end
    end
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:uuid, :within, :location_name)
    end
  end
end
