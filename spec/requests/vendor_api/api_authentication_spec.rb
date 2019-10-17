require 'rails_helper'

RSpec.describe 'API Authentication', type: :request do
  include VendorApiSpecHelpers

  it 'returns succesfully if the user has a valid token' do
    unhashed_token = VendorApiToken.create_with_random_token!(provider: create(:provider))

    get '/api/v1/ping', headers: { 'Authorization' => "Bearer #{unhashed_token}" }

    expect(response).to have_http_status(200)
  end

  it 'returns an error if no Authorization header is present' do
    get '/api/v1/ping'

    expect(response).to have_http_status(401)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'returns an error if the token is incorrect' do
    get '/api/v1/ping', headers: { "Authorization": 'invalid-token' }

    expect(response).to have_http_status(401)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'returns an error if no API token is present' do
    get '/api/v1/ping', headers: { "Authorization": nil }

    expect(response).to have_http_status(401)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end
end
