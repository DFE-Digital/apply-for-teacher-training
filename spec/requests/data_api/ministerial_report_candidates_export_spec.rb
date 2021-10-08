require 'rails_helper'

RSpec.describe 'GET /data-api/ministerial-report/candidates/latest', type: :request, sidekiq: true do
  include DataAPISpecHelper

  it_behaves_like 'a TAD API endpoint', '/candidates'

  it 'returns the latest ministerial report candidates export' do
    create(:submitted_application_choice, :with_completed_application_form, status: 'rejected')

    data_export = DataExport.create!(
      name: 'Daily export of the candidates ministerial report',
      export_type: :ministerial_report_candidates_export,
    )
    DataExporter.perform_async(SupportInterface::MinisterialReportCandidatesExport, data_export.id)

    get_api_request '/data-api/ministerial-report/candidates/latest', token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(response.body).to start_with('subject,candidates,candidates_holding_offers,candidates_that_have_accepted_offers,declined_candidates,rejected_candidates,candidates_that_have_withdrawn_offers')
  end
end
