require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1/spec.yml', type: :request do
  it 'returns the spec in YAML format' do
    get '/api/v1/spec.yml'

    expect(response).to have_http_status(200)
    expect(response.body).to match 'openapi: 3.0.0'
  end
end
