require 'rails_helper'

RSpec.describe 'GET /register-api/applications', type: :request do
  include RegisterAPISpecHelper

  it 'does not allow access to the API from other data users' do
    api_token = ServiceAPIUser.test_data_user.create_magic_link_token!
    get_api_request "/register-api/applications?recruitment_cycle_year=#{RecruitmentCycle.current_year}", token: api_token
    expect(response).to have_http_status(:unauthorized)
  end

  it 'allows access to the API for Register users' do
    get_api_request "/register-api/applications?recruitment_cycle_year=#{RecruitmentCycle.current_year}", token: register_api_token

    expect(response).to have_http_status(:success)
  end

  it 'returns an error if the `recruitment_cycle_year` parameter is missing' do
    get_api_request '/register-api/applications', token: register_api_token

    expect(response).to have_http_status(422)
    expect(error_response['message']).to eql('param is missing or the value is empty: recruitment_cycle_year')
  end

  it 'returns an error if the `recruitment_cycle_year` parameter is incorrect year' do
    get_api_request '/register-api/applications?recruitment_cycle_year=2008', token: register_api_token

    expect(response).to have_http_status(422)
    expect(error_response['message']).to eql('Parameter is invalid: recruitment_cycle_year')
  end

  it 'returns HTTP status 422 given an unparseable `changed_since` date value' do
    get_api_request "/register-api/applications?changed_since=17/07/2020T12:00:42Z&recruitment_cycle_year=#{RecruitmentCycle.current_year}", token: register_api_token

    expect(response).to have_http_status(422)
    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): changed_since')
  end

  it 'returns HTTP status 422 when encountering a KeyError from ActiveSupport::TimeZone' do
    get_api_request "/register-api/applications?changed_since=12936&recruitment_cycle_year=#{RecruitmentCycle.current_year}", token: register_api_token

    expect(response).to have_http_status(422)
    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): changed_since')
  end

  it 'returns HTTP status 422 given a parseable but nonsensensical `changed_since` date value' do
    get_api_request "/register-api/applications?changed_since=-004713-03-23T11:52:19.448Z&recruitment_cycle_year=#{RecruitmentCycle.current_year}", token: register_api_token

    expect(response).to have_http_status(422)
    expect(error_response['message']).to eql('Parameter is invalid (date is nonsense): changed_since')
  end
end
