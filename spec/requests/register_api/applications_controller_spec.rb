require 'rails_helper'

RSpec.describe 'GET /register-api/applications', type: :request, sidekiq: true do
  it 'verifies the API token' do
    get '/register-api/applications', headers: {}

    expect(response).to have_http_status(:unauthorized)
  end

  it 'does not allow access to the API from other data users' do
    api_token = ServiceAPIUser.test_data_user.create_magic_link_token!

    headers = { 'Authorization' => "Bearer #{api_token}" }

    get "/register-api/applications?recruitment_cycle_year=#{RecruitmentCycle.current_year}", headers: headers

    expect(response).to have_http_status(:unauthorized)
  end

  it 'allows access to the API for Register users' do
    api_token = ServiceAPIUser.register_user.create_magic_link_token!

    headers = { 'Authorization' => "Bearer #{api_token}" }

    get "/register-api/applications?recruitment_cycle_year=#{RecruitmentCycle.current_year}", headers: headers

    expect(response).to have_http_status(:success)
  end
end
