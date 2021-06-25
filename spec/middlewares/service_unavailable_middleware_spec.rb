require 'rails_helper'

RSpec.describe ServiceUnavailableMiddleware, type: :request do
  let(:status) { 200 }
  let(:headers) { { 'HEADER' => 'Yeah!' } }
  let(:mock_response) { ['Hellowwworlds!'] }

  def mock_app
    main_app = lambda { |env|
      @env = env
      [status, headers, @body]
    }

    builder = Rack::Builder.new
    builder.use ServiceUnavailableMiddleware
    builder.run main_app
    @app = builder.to_app
  end

  before do
    FeatureFlag.activate(:service_unavailable_page)
    mock_app
  end

  describe '#call on a app path' do
    it 'returns a 503' do
      get '/provider'

      expect(response.status).to eq(503)
    end

    it 'returns the correct content type' do
      get '/provider'

      expect(response.header['Content-type']).to include('text/html')
    end

    context 'when feature flag is off' do
      it 'returns a 200' do
        FeatureFlag.deactivate(:service_unavailable_page)
        get '/provider'

        expect(response.status).to eq(200)
      end
    end
  end

  describe '#call on an API path' do
    it 'returns a 503' do
      get '/api/v1/applications/1', params: { foo: 'bar' }

      expect(response.status).to eq(503)
    end

    it 'returns the correct content type' do
      get '/api/v1/applications/1', params: { foo: 'bar' }

      expect(response.header['Content-type']).to include('application/json')
    end

    context 'when feature flag is off' do
      it 'returns a 200' do
        FeatureFlag.deactivate(:service_unavailable_page)
        get '/api/v1/applications/1', params: { foo: 'bar' }

        expect(response.status).not_to eq(200)
      end
    end
  end

  describe '#call on monitoring paths' do
    it 'returns a 200 when integrations path' do
      get '/integrations/monitoring/all'

      expect(response.status).to eq(200)
    end

    it 'returns a 200 when check path' do
      get '/check'

      expect(response.status).to eq(200)
    end
  end
end
