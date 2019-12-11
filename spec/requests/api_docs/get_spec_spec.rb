require 'rails_helper'

RSpec.describe 'API Docs - GET /api-docs/spec.yml', type: :request do
  it 'returns the spec in YAML format' do
    get '/api-docs/spec.yml'

    expect(response).to have_http_status(200)
    expect(response.body).to match 'openapi: 3.0.0'
  end
end
