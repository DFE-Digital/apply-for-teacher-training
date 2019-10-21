require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1/applications', type: :request do
  include VendorApiSpecHelpers
  include CourseOptionHelpers

  it 'returns applications of the authenticated provider' do
    create_list(
      :application_choice,
      2,
      course_option: course_option_for_provider(provider: currently_authenticated_provider),
    )

    create_list(
      :application_choice,
      1,
      course_option: course_option_for_provider(provider: alternate_provider),
    )

    get_api_request "/api/v1/applications?since=#{(Time.now - 1.days).iso8601}"
    expect(parsed_response['data'].size).to be(2)
  end

  it 'returns applications filtered with `since`' do
    Timecop.travel(Time.now - 2.days) do
      create(
        :application_choice,
        course_option: course_option_for_provider(provider: currently_authenticated_provider),
      )
    end

    create(
      :application_choice,
      course_option: course_option_for_provider(provider: currently_authenticated_provider),
    )

    get_api_request "/api/v1/applications?since=#{(Time.now - 1.days).iso8601}"

    expect(parsed_response['data'].size).to be(1)
  end

  it 'returns a response that is valid according to the OpenAPI schema' do
    create(:application_choice, course: create(:course, provider: currently_authenticated_provider))

    get_api_request "/api/v1/applications?since=#{(Time.now - 1.days).iso8601}"

    expect(parsed_response).to be_valid_against_openapi_schema('MultipleApplicationsResponse')
  end

  it 'returns an error if the `since` parameter is missing' do
    get_api_request '/api/v1/applications'

    expect(response).to have_http_status(422)

    expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse')

    expect(error_response['message']).to eql('param is missing or the value is empty: since')
  end
end
