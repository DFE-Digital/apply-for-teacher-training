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

  it 'can safely return candidates without an application form who signed up this cycle' do
    create(:candidate)
    create(:completed_application_form)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(2)
  end

  it 'does not return candidates without application forms which signed up during the previous recruitment_cycle' do
    create(:candidate, created_at: 1.year.ago)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape(2.years.ago.iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(0)
  end

  it 'does not return candidates who only have application forms in the previous cycle' do
    candidate = create(:candidate, created_at: 1.year.ago)
    create(:completed_application_form, recruitment_cycle_year: RecruitmentCycle.previous_year, candidate: candidate)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape(2.years.ago.iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(0)
  end

  it 'returns candidates who have application forms in the current cycle' do
    candidate = create(:candidate, created_at: 1.year.ago)
    create(:completed_application_form, recruitment_cycle_year: RecruitmentCycle.previous_year, candidate: candidate)
    create(:completed_application_form, candidate: candidate)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape(2.years.ago.iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(1)
  end

  it 'returns applications ordered by created_at timestamp' do
    candidate = create(:candidate)
    application_forms = create_list(
      :completed_application_form,
      2,
      candidate: candidate,
    )
    application_forms.second.update(created_at: 1.minute.ago)

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}", token: candidate_api_token

    response_data = parsed_response.dig('data', 0, 'attributes', 'application_forms')

    expect(response_data.size).to eq(2)

    expect(response_data.first['id']).to eq(application_forms.second.id)
    expect(response_data.first['application_phase']).to eq(application_forms.second.phase)
    expect(response_data.first['application_status']).to eq(ProcessState.new(application_forms.second).state.to_s)
    expect(response_data.first['recruitment_cycle_year']).to eq(application_forms.second.recruitment_cycle_year)
    expect(response_data.first['submitted_at']).to eq(application_forms.second.submitted_at.iso8601)
    expect(response_data.second['id']).to eq(application_forms.first.id)
    expect(response_data.second['application_phase']).to eq(application_forms.first.phase)
    expect(response_data.second['application_status']).to eq(ProcessState.new(application_forms.first).state.to_s)
    expect(response_data.first['recruitment_cycle_year']).to eq(application_forms.second.recruitment_cycle_year)
    expect(response_data.first['submitted_at']).to eq(application_forms.second.submitted_at.iso8601)
  end

  it 'returns the correct page and the default page items' do
    Timecop.travel(Time.zone.now - 2.days) do
      create(:completed_application_form)
    end

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}&page=1", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(response.headers['page-items']).to eq '500'
    expect(response.headers['current-page']).to eq '1'
  end

  it 'navigates through the pages' do
    create_list(:candidate, 4, application_forms: [create(:completed_application_form)])

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}&page=1&per_page=2", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(response.headers['current-page']).to eq '1'

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}&page=2&per_page=2", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(response.headers['current-page']).to eq '2'
  end

  it 'returns the correct page items from the per_page parameter' do
    Timecop.travel(Time.zone.now - 2.days) do
      candidate = create(:candidate)
      create(:completed_application_form, candidate: candidate)
    end

    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}&per_page=20", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(response.headers['page-items']).to eq '20'
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

  it 'returns HTTP status 422 when given a parseable page value that exceeds the range' do
    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}&page=2", token: candidate_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql("expected 'page' parameter to be between 1 and 1, got 2")
    expect(parsed_response).to be_valid_against_openapi_schema('PageParameterInvalidResponse')
  end

  it 'returns HTTP status 422 when given a parseable per_page value that exceeds the max value' do
    max_value = CandidateAPI::CandidatesController::MAX_PER_PAGE
    get_api_request "/candidate-api/candidates?updated_since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}&page=2&per_page=#{max_value + 1}", token: candidate_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql("the 'per_page' parameter cannot exceed #{max_value} results per page")
    expect(parsed_response).to be_valid_against_openapi_schema('PerPageParameterInvalidResponse')
  end
end
