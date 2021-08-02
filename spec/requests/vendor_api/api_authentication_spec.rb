require 'rails_helper'

RSpec.describe 'API Authentication', type: :request do
  include VendorAPISpecHelpers

  it 'returns succesfully if the user has a valid token' do
    unhashed_token = VendorAPIToken.create_with_random_token!(provider: create(:provider))

    get '/api/v1/ping', headers: { Authorization: "Bearer #{unhashed_token}" }

    expect(response).to have_http_status(:ok)
  end

  it 'remembers when a token was last used' do
    unhashed_token = VendorAPIToken.create_with_random_token!(provider: create(:provider))

    expect {
      get '/api/v1/ping', headers: { Authorization: "Bearer #{unhashed_token}" }
    }.to change {
      VendorAPIToken.find_by_unhashed_token(unhashed_token).last_used_at
    }
  end

  it 'returns an error if no Authorization header is present' do
    get '/api/v1/ping'

    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'returns an error if the token is incorrect' do
    get '/api/v1/ping', headers: { Authorization: 'invalid-token' }

    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'returns an error if no API token is present' do
    get '/api/v1/ping', headers: { Authorization: nil }

    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end
end
