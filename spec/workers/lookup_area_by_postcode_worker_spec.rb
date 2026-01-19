require 'rails_helper'

RSpec.describe LookupAreaByPostcodeWorker do
  let(:api) { instance_double(Postcodes::IO) }
  let(:result) { double }

  before do
    allow(Postcodes::IO).to receive(:new).and_return(api)
    allow(api).to receive(:lookup).and_return(result)
  end

  describe 'region from postcode' do
    let(:application_form) { create(:application_form, postcode: 'SW1A 1AA') }

    context 'when the API returns an English region' do
      before do
        allow(result).to receive_messages(postcode: 'SW1A 1AA', region: 'South West', country: 'England')
      end

      it 'updates the region code' do
        described_class.new.perform(application_form.id)
        expect(application_form.reload.region_code).to eq('south_west')
      end
    end

    context 'when the API returns Scotland' do
      before do
        allow(result).to receive_messages(postcode: 'SW1A 1AA', region: nil, country: 'Scotland')
      end

      it 'updates the region code' do
        described_class.new.perform(application_form.id)
        expect(application_form.reload.region_code).to eq('scotland')
      end
    end
  end

  describe 'when application has badly formatted postcode' do
    let(:application_form) { create(:application_form, postcode: 'sw1A  1aa') }

    before do
      allow(result).to receive_messages(postcode: 'SW1A 1AA', region: 'South West', country: 'England')
    end

    it 'corrects postcode' do
      described_class.new.perform(application_form.id)
      expect(application_form.reload.postcode).to eq('SW1A 1AA')
    end
  end

  describe 'when no results are returned' do
    let(:application_form) { create(:application_form, postcode: 'sw1A  1aa') }

    before do
      allow(result).to receive_messages(postcode: nil, region: nil, country: nil)
    end

    it 'does not update region or postcode' do
      described_class.new.perform(application_form.id)
      application_form.reload
      expect(application_form.postcode).to eq('sw1A  1aa')
      expect(application_form.region_code).to be_nil
    end
  end

  describe 'when postcode is not present on application form' do
    let(:application_form) { create(:application_form, postcode: 'sw1A  1aa') }

    it 'does not call postcode IO' do
      expect(Postcodes::IO).not_to have_received(:new)
    end
  end
end
