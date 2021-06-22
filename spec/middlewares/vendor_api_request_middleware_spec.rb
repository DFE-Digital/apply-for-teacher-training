require 'rails_helper'

RSpec.describe VendorAPIRequestMiddleware, type: :request do
  let(:status) { 200 }
  let(:headers) { { HEADER: 'Yeah!' } }
  let(:mock_response) { ['Hellowwworlds!'] }

  def mock_app
    main_app = lambda { |env|
      @env = env
      [status, headers, @body || mock_response]
    }

    builder = Rack::Builder.new
    builder.use VendorAPIRequestMiddleware
    builder.run main_app
    @app = builder.to_app
  end

  before do
    mock_app
    allow(VendorAPIRequestWorker).to receive(:perform_async)
  end

  describe '#call on a non-API path' do
    it 'does not enqueue a background job' do
      get '/candidate'

      expect(VendorAPIRequestWorker).not_to have_received(:perform_async)
    end
  end

  describe '#call on an API path' do
    it 'enqueues a worker job' do
      get '/api/v1/applications/1', params: { foo: 'bar' }

      expect(VendorAPIRequestWorker).to have_received(:perform_async).with(
        hash_including(path: '/api/v1/applications/1', params: { 'foo' => 'bar' }, method: 'GET'), anything, 401, anything
      )
    end
  end

  describe '#call on an API path with POST data' do
    it 'enqueues a worker job including post data' do
      post '/api/v1/applications/1/offer', as: :json, params: { foo: 'bar' }

      expect(VendorAPIRequestWorker).to have_received(:perform_async).with(
        hash_including(path: '/api/v1/applications/1/offer', body: '{"foo":"bar"}', method: 'POST'), anything, 401, anything
      )
    end
  end

  describe '#call on an API path when Redis is unavailable' do
    it 'logs the Redis exception and returns' do
      allow(Rails.logger).to receive(:warn)
      allow(VendorAPIRequestWorker).to receive(:perform_async).and_raise(Redis::BaseError.new('Oops no Redis'))

      get '/api/v1/applications/1'

      expect(Rails.logger).to have_received(:warn).with('Oops no Redis')
    end
  end
end
