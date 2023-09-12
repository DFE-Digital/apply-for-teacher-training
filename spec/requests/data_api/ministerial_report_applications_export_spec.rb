require 'rails_helper'

RSpec.describe 'GET /data-api/ministerial-report/applications/latest', :sidekiq do
  include DataAPISpecHelper

  it_behaves_like 'a TAD API endpoint', '/applications'

  it 'returns the latest ministerial report applications export' do
    create(:application_choice, :awaiting_provider_decision, :with_completed_application_form, status: 'rejected')

    data_export = DataExport.create!(
      name: 'Daily export of the applications ministerial report',
      export_type: :ministerial_report_applications_export,
    )
    DataExporter.perform_async(SupportInterface::MinisterialReportApplicationsExport.to_s, data_export.id)

    get_api_request '/data-api/ministerial-report/applications/latest', token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(response.body).to start_with('subject,applications,offer_received,accepted,application_declined,application_rejected,application_withdrawn')
  end
end
