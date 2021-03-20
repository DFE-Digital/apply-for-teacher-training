require 'rails_helper'

RSpec.describe 'GET /data-api/tad-data-exports', type: :request, sidekiq: true do
  include DataAPISpecHelper

  it_behaves_like 'a TAD API endpoint', '/'

  it 'returns a list of data exports' do
    create(:submitted_application_choice, :with_completed_application_form, status: 'rejected')

    data_export = DataExport.create!(name: 'Daily export of applications for TAD')
    DataExporter.perform_async(DataAPI::TADExport, data_export.id)

    data_export = DataExport.create!(name: 'Daily export of applications for TAD')
    DataExporter.perform_async(DataAPI::TADExport, data_export.id)

    get_api_request '/data-api/tad-data-exports', token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(parsed_response).to be_valid_against_openapi_schema('TADDataExportList')
  end
end
