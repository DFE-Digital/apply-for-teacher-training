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

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('param is missing or the value is empty: updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse')
  end

  it 'returns applications filtered with `updated_since`' do
    Timecop.travel(Time.zone.now - 2.days) do
      candidate = create(:candidate)
      create(:completed_application_form, candidate: candidate)
    end

    second_candidate = create(:candidate)
    create(:completed_application_form, candidate: second_candidate)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(1)
  end

  it 'can safely return candidates without an application form' do
    candidate = create(:candidate)
    create(:completed_application_form, candidate: candidate)

    create(:candidate)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(2)
  end

  it 'returns applications ordered by created_at timestamp' do
    candidate = create(:candidate)
    application_forms = create_list(
      :completed_application_form,
      2,
      candidate: candidate,
    )
    application_forms.first.update(created_at: 1.hour.ago)
    application_forms.second.update(created_at: 1.minute.ago)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", token: candidate_api_token

    response_data = parsed_response.dig('data', 0, 'attributes', 'application_forms', 'data', 0)
    expect(response_data.size).to eq(2)

    expect(response_data.first['id']).to eq(application_forms.second.id)
    expect(response_data.second['id']).to eq(application_forms.first.id)

    application_forms.first.update(created_at: 10.seconds.ago)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", token: candidate_api_token

    response_data = parsed_response.dig('data', 0, 'attributes', 'application_forms', 'data', 0)

    expect(response_data.first['id']).to eq(application_forms.first.id)
    expect(response_data.second['id']).to eq(application_forms.second.id)
  end

  it 'returns an error if the token is incorrect' do
    get "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", headers: { Authorization: 'invalid-token' }

    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'returns an error if no API token is present' do
    get "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", headers: { Authorization: nil }

    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'returns HTTP status 422 given an unparseable `updated_since` date value' do
    get_api_request '/candidate-api/candidates?updated_since=17/07/2020T12:00:42Z', token: candidate_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterInvalidResponse')
  end

  it 'returns HTTP status 422 when encountering a KeyError from ActiveSupport::TimeZone' do
    get_api_request '/candidate-api/candidates?updated_since=12936', token: candidate_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterInvalidResponse')
  end

  it 'returns HTTP status 422 given a parseable but nonsensensical `updated_since` date value' do
    get_api_request '/candidate-api/candidates?updated_since=-004713-03-23T11:52:19.448Z', token: candidate_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('Parameter is invalid (date is nonsense): updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterInvalidResponse')
  end
end
