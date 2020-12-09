require 'rails_helper'

RSpec.describe GeocodeApplicationAddressWorker do
  describe '#perform' do
    it 'does nothing if a Geocoder API key is not set' do
      allow(Geocoder.config).to receive(:api_key).and_return(nil)
      application = create(:application_form)
      allow(application).to receive(:geocode)

      described_class.new.perform(application.id)

      expect(application).not_to have_received(:geocode)
    end

    context 'with an API key set' do
      before { allow(Geocoder.config).to receive(:api_key).and_return('SOME_KEY') }

      it 'saves coordinates returned by the geocoder' do
        application = create(:application_form)
        allow(application).to receive(:geocode).and_return([51.499399, -0.124808])
        allow(ApplicationForm).to receive(:find).with(application.id).and_return(application)

        described_class.new.perform(application.id)

        expect(application.latitude).to eq(51.499399)
        expect(application.longitude).to eq(-0.124808)
      end

      it 'sets location to nil if coordinates returned by the geocoder are outside UK' do
        application = create(:application_form)
        allow(application).to receive(:geocode).and_return([13.7244416, 100.35291])
        allow(ApplicationForm).to receive(:find).with(application.id).and_return(application)

        described_class.new.perform(application.id)

        expect(application.latitude).to be_nil
        expect(application.longitude).to be_nil
      end

      it 'does not use result if geocoder returns nil' do
        application = create(:application_form, latitude: 51.23456, longitude: 1.23456)
        allow(application).to receive(:geocode).and_return(nil)
        allow(ApplicationForm).to receive(:find).with(application.id).and_return(application)

        described_class.new.perform(application.id)

        application.reload
        expect(application.latitude).to eq 51.23456
        expect(application.longitude).to eq 1.23456
      end
    end
  end
end
