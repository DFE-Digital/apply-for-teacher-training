require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1/applications', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it 'returns applications of the authenticated provider' do
    create_list(
      :submitted_application_choice,
      2,
      :with_completed_application_form,
      course_option: course_option_for_provider(provider: currently_authenticated_provider),
      status: 'awaiting_provider_decision',
    )

    alternate_provider = create(:provider, code: 'DIFFERENT')

    create_list(
      :submitted_application_choice,
      1,
      course_option: course_option_for_provider(provider: alternate_provider),
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"
    expect(parsed_response['data'].size).to eq(2)
  end

  it 'returns applications filtered with `since`' do
    Timecop.travel(Time.zone.now - 2.days) do
      create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
    end

    create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"

    expect(parsed_response['data'].size).to eq(1)
  end

  it 'returns a response that is valid according to the OpenAPI schema' do
    create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"

    expect(parsed_response).to be_valid_against_openapi_schema('MultipleApplicationsResponse')
  end

  it 'returns an error if the `since` parameter is missing' do
    get_api_request '/api/v1/applications'

    expect(response).to have_http_status(422)

    expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse')

    expect(error_response['message']).to eql('param is missing or the value is empty: since')
  end

  it 'returns HTTP status 422 given an unparseable `since` date value' do
    get_api_request '/api/v1/applications?since=17/07/2020T12:00:42Z'

    expect(response).to have_http_status(422)

    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')

    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): since')
  end

  it 'returns HTTP status 422 when encountering a KeyError from ActiveSupport::TimeZone' do
    get_api_request '/api/v1/applications?since=12936'

    expect(response).to have_http_status(422)

    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')

    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): since')
  end

  it 'returns HTTP status 422 given a parseable but nonsensensical `since` date value' do
    get_api_request '/api/v1/applications?since=-004713-03-23T11:52:19.448Z' # this happened

    expect(response).to have_http_status(422)

    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')

    expect(error_response['message']).to eql('Parameter is invalid (date is nonsense): since')
  end

  it 'returns applications that are in a viewable state' do
    create_list(
      :submitted_application_choice,
      2,
      :with_completed_application_form,
      course_option: course_option_for_provider(provider: currently_authenticated_provider),
      status: :awaiting_provider_decision,
    )

    create_list(
      :submitted_application_choice,
      3,
      course_option: course_option_for_provider(provider: currently_authenticated_provider),
      status: :unsubmitted,
    )

    get_api_request "/api/v1/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"

    expect(parsed_response['data'].size).to eq(2)
  end

  it 'returns applications ordered by updated_at timestamp' do
    application_choices = create_list(
      :submitted_application_choice,
      3,
      :with_completed_application_form,
      course_option: course_option_for_provider(provider: currently_authenticated_provider),
      status: :awaiting_provider_decision,
    )
    application_choices.first.update(updated_at: 1.hour.ago)
    application_choices.second.update(updated_at: 1.minute.ago)
    application_choices.last.update(updated_at: 10.minutes.ago)

    get_api_request "/api/v1/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"

    response_data = parsed_response['data']
    expect(response_data.size).to eq(3)

    expect(response_data.first['id']).to eq(application_choices.second.id.to_s)
    expect(response_data.second['id']).to eq(application_choices.last.id.to_s)
    expect(response_data.last['id']).to eq(application_choices.first.id.to_s)

    application_choices.first.update(updated_at: 10.seconds.ago)

    get_api_request "/api/v1/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"

    response_data = parsed_response['data']

    expect(response_data.first['id']).to eq(application_choices.first.id.to_s)
    expect(response_data.second['id']).to eq(application_choices.second.id.to_s)
    expect(response_data.last['id']).to eq(application_choices.last.id.to_s)
  end
end
