require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/test-data/clear', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it 'clears test data' do
    create(
      :application_choice,
      :awaiting_provider_decision,
      :with_completed_application_form,
      course_option: course_option_for_provider(provider: currently_authenticated_provider),
    )

    expect {
      post_api_request('/api/v1/test-data/clear')
    }.to change {
      get_api_request('/api/v1/applications?since=1970-01-01')
      parsed_response['data'].count
    }.from(1).to(0)
  end

  it 'destroys the Candidate record, which causes all other records to be destroyed' do
    create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_for_provider(provider: currently_authenticated_provider),
    )

    expect {
      post_api_request('/api/v1/test-data/clear')
    }.to change {
      Candidate.count
    }.from(1).to(0)
  end

  it 'destroys applications accredited by the current provider' do
    create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_for_accredited_provider(
        accredited_provider: currently_authenticated_provider,
        provider: create(:provider),
      ),
    )

    expect { post_api_request('/api/v1/test-data/clear') }.to change(Candidate, :count).from(1).to(0)
      .and change(ApplicationForm, :count).from(1).to(0)
      .and change(ApplicationChoice, :count).from(1).to(0)
  end

  it 'returns responses conforming to the schema' do
    post_api_request('/api/v1/test-data/clear')
    expect(parsed_response).to be_valid_against_openapi_schema('OkResponse')
  end
end
