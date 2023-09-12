require 'rails_helper'

RSpec.describe 'GET /data-api/tad-data-exports', :sidekiq do
  include DataAPISpecHelper

  it_behaves_like 'an API endpoint requiring a date param', '/data-api/tad-data-exports', 'updated_since', ServiceAPIUser.tad_user.create_magic_link_token!

  it 'allows access to the API for TAD users' do
    get_api_request "/data-api/tad-data-exports?updated_since=#{CGI.escape(1.month.ago.iso8601)}", token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(parsed_response).to be_valid_against_openapi_schema('TADDataExportList')
  end

  it 'returns a list of data exports' do
    get_api_request "/data-api/tad-data-exports?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(parsed_response).to be_valid_against_openapi_schema('TADDataExportList')
  end

  context 'when data export is exported' do
    before do
      create(:application_choice, :awaiting_provider_decision, :with_completed_application_form)

      data_export = DataExport.create!(name: 'Daily export of applications for TAD', export_type: :tad_applications)
      DataExporter.perform_async(DataAPI::TADExport.to_s, data_export.id)
    end

    it 'returns data exports response JSON values as expected' do
      data_export = DataExport.last

      get_api_request "/data-api/tad-data-exports?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: tad_api_token

      response_data = parsed_response.dig('data', 0)

      expect(response_data['export_date'].to_time.to_i).to be_within(1).of(Time.zone.now.to_i)
      expect(response_data['description']).to eq('Daily export of applications for TAD')
      expect(response_data['url']).to eq("http://www.example.com/data-api/tad-data-exports/#{data_export.id}")
      expect(response_data['updated_at'].to_time.to_i).to be_within(1).of(Time.zone.now.to_i)
      expect(parsed_response).to be_valid_against_openapi_schema('TADDataExportList')
    end

    it 'returns data exports filtered by `updated_since`' do
      travel_temporarily_to(2.days.ago) do
        create(:application_choice, :awaiting_provider_decision, :with_completed_application_form)
        data_export = DataExport.create!(name: 'Daily export of applications for TAD', export_type: :tad_applications)
        DataExporter.perform_async(DataAPI::TADExport.to_s, data_export.id)
      end

      get_api_request "/data-api/tad-data-exports?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: tad_api_token

      expect(parsed_response['data'].size).to eq(1)
      expect(DataExport.all.count).to eq(2)
      expect(response).to have_http_status(:success)
      expect(parsed_response).to be_valid_against_openapi_schema('TADDataExportList')
    end
  end
end
