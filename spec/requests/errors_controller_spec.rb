require 'rails_helper'

RSpec.describe ErrorsController do
  describe '#not_found' do
    it 'responds with json for a json request' do
      post '/api/v666/some/cats', headers: { 'HTTP_ACCEPT' => 'application/json' }

      expect(response.status).to eq(404)
      expect(response.header['Content-Type']).to match('application/json')
      expect(JSON.parse(response.body)).to eq({ 'errors' => [{ 'error' => 'NotFound', 'message' => 'Not Found' }] })
    end

    it 'responds with html for all other requests' do
      get '/some/cats', headers: { 'HTTP_ACCEPT' => 'text/plain' }

      expect(response.status).to eq(404)
      expect(response.header['Content-Type']).to match('text/html')
      expect(response.body).to match('Page not found')
    end
  end
end
