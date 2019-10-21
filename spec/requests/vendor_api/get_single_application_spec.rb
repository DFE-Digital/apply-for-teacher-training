require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1/applications/:application_id', type: :request do
  include VendorApiSpecHelpers
  include CourseOptionHelpers

  it 'returns a response that is valid according to the OpenAPI schema' do
    application_choice = create(
      :application_choice,
      course_option: course_option_for_provider(provider: currently_authenticated_provider),
    )

    get_api_request "/api/v1/applications/#{application_choice.id}"

    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
  end

  it "returns a not found error if the application can't be found" do
    get_api_request '/api/v1/applications/asu7dvt87asd'

    expect(response).to have_http_status(404)

    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')

    expect(error_response['message']).to eql('Could not find an application with ID asu7dvt87asd')
  end

  it "returns a not found error if the application doesn't belong to the provider" do
    application_choice = create(:application_choice)

    get_api_request "/api/v1/applications/#{application_choice.id}"

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql("Could not find an application with ID #{application_choice.id}")
  end
end
