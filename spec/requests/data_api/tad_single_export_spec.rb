require 'rails_helper'

RSpec.describe 'GET /data-api/tad-data-exports/:id', type: :request, sidekiq: true do
  include DataAPISpecHelper

  it_behaves_like 'a TAD API endpoint', '/123'

  it 'returns the latest data export' do
    create(:submitted_application_choice, :with_completed_application_form, status: 'rejected')

    data_export = DataExport.create!(
      name: 'Daily export of applications for TAD',
      export_type: :tad_applications,
    )
    DataExporter.perform_async(DataAPI::TADExport, data_export.id)

    get_api_request "/data-api/tad-data-exports/#{data_export.id}", token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(response.body).to start_with('extract_date,candidate_id,application_choice_id,application_form_id')
  end
end
