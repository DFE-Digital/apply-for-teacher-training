require 'rails_helper'

RSpec.describe 'GET /data-api/applications-by-subject-domicile-and-nationality/latest', :sidekiq do
  include DataAPISpecHelper

  it 'verifies the API token' do
    get_api_request '/data-api/applications-by-subject-domicile-and-nationality/latest', token: nil

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns the latest data export' do
    create(:application_choice, :awaiting_provider_decision, :with_completed_application_form, status: 'rejected')

    DataAPI::TADSubjectDomicileNationalityExport.run_weekly

    get_api_request '/data-api/applications-by-subject-domicile-and-nationality/latest', token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(response.body).to start_with(
      'subject,candidate_domicile,candidate_nationality,adjusted_applications,adjusted_offers,pending_conditions,recruited',
    )
  end
end
