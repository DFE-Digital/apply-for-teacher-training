require 'rails_helper'

RSpec.describe 'GET /candidate-api/candidates', type: :request do
  include CandidateAPISpecHelper

  it 'does not allow access to the API from other data users' do
    api_token = ServiceAPIUser.test_data_user.create_magic_link_token!
    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.month).iso8601)}", token: api_token
    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'allows access to the API for Candidate users' do
    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.month).iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:success)
    expect(parsed_response).to be_valid_against_openapi_schema('CandidateList')
  end

  it 'returns an error if the `updated_since` parameter is missing' do
    get_api_request '/candidate-api/candidates', token: candidate_api_token

    expect(response).to have_http_status(422)
    expect(error_response['message']).to eql('param is missing or the value is empty: updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse')
  end

  it 'returns applications filtered with `updated_since`' do
    Timecop.travel(Time.zone.now - 2.days) do
      create(:candidate)
    end

    create(:candidate)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(200)
    expect(parsed_response['data'].size).to eq(1)
  end

  it 'returns an error if the token is incorrect' do
    get "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", headers: { "Authorization": 'invalid-token' }

    expect(response).to have_http_status(401)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'returns an error if no API token is present' do
    get "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", headers: { "Authorization": nil }

    expect(response).to have_http_status(401)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end
end
