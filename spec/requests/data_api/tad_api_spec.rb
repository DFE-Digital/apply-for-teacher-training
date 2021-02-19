require 'rails_helper'

RSpec.describe 'GET /data-api/tad-data-exports/latest', type: :request, sidekiq: true do
  it 'verifies the API token' do
    get '/data-api/tad-data-exports/latest', headers: {}

    expect(response).to have_http_status(:unauthorized)
  end

  it 'only allows access to the API for TAD, and not other data users' do
    api_token = DataAPIUser.test_data_user.create_magic_link_token!

    headers = { 'Authorization' => "Bearer #{api_token}" }

    get '/data-api/tad-data-exports/latest', headers: headers

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns the latest data export' do
    create(:submitted_application_choice, :with_completed_application_form, status: 'rejected')

    data_export = DataExport.create!(name: 'Daily export of applications for TAD')
    DataExporter.perform_async(DataAPI::TADExport, data_export.id)

    api_token = DataAPIUser.tad_user.create_magic_link_token!

    headers = { 'Authorization' => "Bearer #{api_token}" }

    get '/data-api/tad-data-exports/latest', headers: headers

    expect(response).to have_http_status(:success)
    expect(response.body).to start_with('extract_date,candidate_id,application_choice_id,application_form_id')
  end
end
