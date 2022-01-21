require 'rails_helper'

RSpec.describe 'GET /data-api/tad-data-exports', type: :request, sidekiq: true do
  include DataAPISpecHelper

  let!(:create_data_export) do
    DataExport.create!(name: 'Daily export of applications for TAD', export_type: :tad_applications)
  end

  let!(:export_data_export) do
    DataExporter.perform_async(DataAPI::TADExport, create_data_export.id)
  end

  it_behaves_like 'a TAD API endpoint', '/'

  it 'allows access to the API for TAD users' do
    get_api_request "/data-api/tad-data-exports?updated_since=#{CGI.escape(1.month.ago.iso8601)}", token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(parsed_response).to be_valid_against_openapi_schema('TADDataExportList')
  end

  it 'returns a list of data exports' do
    create(:submitted_application_choice, :with_completed_application_form)

    create_data_export
    export_data_export

    get_api_request "/data-api/tad-data-exports?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(parsed_response).to be_valid_against_openapi_schema('TADDataExportList')
  end

  it 'returns data exports response JSON values as expected' do
    create(:submitted_application_choice, :with_completed_application_form)

    data_export = create_data_export
    export_data_export

    data_export = DataExport.find(data_export.id)

    get_api_request "/data-api/tad-data-exports?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: tad_api_token

    response_data = parsed_response.dig('data', 0)

    expect(response_data['export_date'].to_time.iso8601).to eq(data_export.completed_at.iso8601)
    expect(response_data['description']).to eq(data_export.name)
    expect(response_data['url']).to eq(data_api_tad_export_url(data_export.id))
    expect(response_data['updated_at'].to_time.iso8601).to eq(data_export.updated_at.iso8601)
  end

  it 'returns data exports filtered by `updated_since`' do
    Timecop.travel(2.days.ago) do
      create(:submitted_application_choice, :with_completed_application_form)
      create_data_export
      export_data_export
    end

    create(:submitted_application_choice, :with_completed_application_form)

    create_data_export
    export_data_export

    get_api_request "/data-api/tad-data-exports?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: tad_api_token

    expect(parsed_response['data'].size).to eq(1)
    expect(response).to have_http_status(:success)
  end

  it 'returns an error if the `updated_since` parameter is missing' do
    get_api_request '/data-api/tad-data-exports', token: tad_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('param is missing or the value is empty: updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse')
  end

  it 'returns HTTP status 422 given an unparseable `updated_since` date value' do
    get_api_request '/data-api/tad-data-exports?updated_since=17/07/2020T12:00:42Z', token: tad_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterInvalidResponse')
  end

  it 'returns HTTP status 422 when encountering a KeyError from ActiveSupport::TimeZone' do
    get_api_request '/data-api/tad-data-exports?updated_since=12936', token: tad_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterInvalidResponse')
  end
end
