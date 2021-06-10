require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/conditions-not-met', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/conditions-not-met'

  it 'confirms the conditions have not been met' do
    attributes = { status: 'pending_conditions', offered_at: Time.zone.now }
    application_choice = create_application_choice_for_currently_authenticated_provider(attributes)
    create(:offer, application_choice: application_choice)

    post_api_request "/api/v1/applications/#{application_choice.id}/conditions-not-met"

    expect(response).to have_http_status(200)
    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
    expect(parsed_response['data']['attributes']['status']).to eq 'conditions_not_met'
  end
end
