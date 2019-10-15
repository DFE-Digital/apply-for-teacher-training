require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1/applications', type: :request do
  include VendorApiSpecHelpers

  it 'returns applications scoped by `provider`' do
    ucl         = create(:provider, code: 'UCL')
    strathclyde = create(:provider, code: 'STR')

    create_list(
      :application_choice, 2,
      course: create(:course, provider: ucl)
    )

    create_list(
      :application_choice, 1,
      course: create(:course, provider: strathclyde)
    )

    get_api_request "/api/v1/applications?provider_ucas_code=UCL&since=#{(Time.now - 1.days).iso8601}"

    expect(parsed_response['data'].size).to be(2)
  end

  it 'returns applications filtered with `since`' do
    ucl = create(:provider, code: 'UCL')

    Timecop.travel(Time.now - 2.days) do
      create(:application_choice, course: create(:course, provider: ucl))
    end

    create(:application_choice, course: create(:course, provider: ucl))

    get_api_request "/api/v1/applications?provider_ucas_code=UCL&since=#{(Time.now - 1.days).iso8601}"

    expect(parsed_response['data'].size).to be(1)
  end

  it 'returns a response that is valid according to the OpenAPI schema' do
    ucl = create(:provider, code: 'UCL')

    create(:application_choice, course: create(:course, provider: ucl))

    get_api_request "/api/v1/applications?provider_ucas_code=UCL&since=#{(Time.now - 1.days).iso8601}"

    expect(parsed_response).to be_valid_against_openapi_schema('MultipleApplicationsResponse')
  end

  it 'returns an error if the `since` parameter is missing' do
    get_api_request '/api/v1/applications?provider_ucas_code=ABC'

    expect(response).to have_http_status(422)

    expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse')

    expect(error_response['message']).to eql('param is missing or the value is empty: since')
  end

  it 'returns an error if the `provider_ucas_code` parameter is missing' do
    get_api_request "/api/v1/applications?since=#{(Time.now - 1.days).iso8601}"

    expect(response).to have_http_status(422)

    expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse')

    expect(error_response['message']).to eql('param is missing or the value is empty: provider_ucas_code')
  end
end
