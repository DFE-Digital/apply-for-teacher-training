require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v2.0/applications' do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  before do
    stub_const('VendorAPI::VERSION', '2.0')
  end

  describe 'pagination' do
    it 'navigates through the pages' do
      travel_temporarily_to(Time.zone.now) do
        application_choices = create_list(
          :application_choice,
          3,
          :with_completed_application_form,
          course_option: course_option_for_provider(provider: currently_authenticated_provider),
          status: :awaiting_provider_decision,
        )

        application_choices.first.update(updated_at: 1.hour.ago)
        application_choices.second.update(updated_at: 1.minute.ago)
        application_choices.last.update(updated_at: 10.minutes.ago)

        get_api_request "/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=1&per_page=2"

        expect(parsed_response).to be_valid_against_openapi_schema('MultipleApplicationsResponse', '2.0')

        response_data = parsed_response['data']
        links_object = parsed_response['links']

        expect(links_object['self']).to eq "http://www.example.com/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=1&per_page=2"
        expect(links_object['prev']).to eq "http://www.example.com/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=&per_page=2"
        expect(links_object['next']).to eq "http://www.example.com/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=2"
        expect(links_object['last']).to eq "http://www.example.com/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=2"

        expect(response_data.first['id']).to eq(application_choices.second.id.to_s)
        expect(response_data.second['id']).to eq(application_choices.last.id.to_s)

        expect(response).to have_http_status(:ok)

        get_api_request "/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=2"

        expect(parsed_response).to be_valid_against_openapi_schema('MultipleApplicationsResponse', '2.0')

        links_object = parsed_response['links']

        expect(links_object['self']).to eq "http://www.example.com/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=2"
        expect(links_object['prev']).to eq "http://www.example.com/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=1&per_page=2"
        expect(links_object['next']).to eq "http://www.example.com/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=&per_page=2"

        expect(parsed_response['data'].first['id']).to eq(application_choices.first.id.to_s)

        expect(response).to have_http_status(:ok)
      end
    end

    it 'returns HTTP status 422 when the page parameter is missing' do
      create_list(
        :application_choice,
        3,
        :with_completed_application_form,
        course_option: course_option_for_provider(provider: currently_authenticated_provider),
        status: :awaiting_provider_decision,
      )

      get_api_request "/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

      expect(response).to have_http_status(:unprocessable_content)
      expect(parsed_response).to contain_schema_with_error(
        'ParameterMissingResponse',
        'param is missing or the value is empty or invalid: page',
      )
    end
  end

  describe 'recording pagination usage on the token' do
    it 'records pagination as true' do
      get_api_request "/api/v2.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=1"

      expect(response).to have_http_status(:ok)
      expect(VendorAPIToken.find_by_unhashed_token(api_token).pagination).to be(true)
    end
  end
end
