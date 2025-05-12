require 'rails_helper'

RSpec.describe GoogleMapsAPI::Client do
  let(:api_key) { ENV['GOOGLE_MAPS_API_KEY'] }
  let(:client) { described_class.new }

  describe '#autocomplete' do
    let(:query) { 'London' }
    let(:autocomplete_api_path) do
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country%3Auk&region=uk&input=#{query}&key=#{api_key}&language=en&types=locality%7Csublocality%7Cpostal_code"
    end
    let(:body) { Pathname.new(Rails.root.join('spec/examples/google_maps_api/autocomplete_london.json')).read }

    context 'when success response' do
      before do
        stub_request(:get, autocomplete_api_path)
          .to_return(
            status: 200,
            body:,
            headers: { 'Content-Type' => 'application/json' },
          )
      end

      it 'returns an array of predictions' do
        result = client.autocomplete(query)

        expect(result).to eq(
          [
            {
              name: 'London, UK',
              place_id: 'ChIJdd4hrwug2EcRmSrV3Vo6llI',
              types: %w[locality political],
            },
          ],
        )
      end
    end

    context 'when no predictions are returned' do
      before do
        stub_request(:get, autocomplete_api_path)
          .to_return(status: 200, body: { predictions: [] }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns an empty array' do
        result = client.autocomplete(query)

        expect(result).to eq([])
      end
    end
  end
end
