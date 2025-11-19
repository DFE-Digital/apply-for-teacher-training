require 'rails_helper'

RSpec.describe 'GET /data-api/ministerial-report/candidates/latest', :sidekiq do
  include DataAPISpecHelper

  it 'verifies the API token' do
    get_api_request '/data-api/ministerial-report/candidates/latest', token: nil

    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'returns the latest ministerial report candidates export' do
    create(:application_choice, :awaiting_provider_decision, :with_completed_application_form, status: 'rejected')

    data_export = DataExport.create!(
      name: 'Daily export of the candidates ministerial report',
      export_type: :ministerial_report_candidates_export,
    )
    DataExporter.perform_async(SupportInterface::MinisterialReportCandidatesExport.to_s, data_export.id)

    get_api_request '/data-api/ministerial-report/candidates/latest', token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(response.body).to start_with(
      'subject,candidates,offer_received,accepted,application_declined,application_rejected,application_withdrawn',
    )
  end
end
