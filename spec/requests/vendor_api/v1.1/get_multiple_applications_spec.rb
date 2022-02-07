require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1.1/applications', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  before do
    stub_const('VendorAPI::VERSION', '1.1')
  end

  describe 'pagination' do
    it 'navigates through the pages' do
      Timecop.freeze(Time.zone.now) do
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

        get_api_request "/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=1&per_page=2"

        response_data = parsed_response['data']
        links_object = parsed_response['links']

        expect(links_object['self']).to eq "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=1&per_page=2"
        expect(links_object['prev']).to eq "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=&per_page=2"
        expect(links_object['next']).to eq "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=2"
        expect(links_object['last']).to eq "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=2"

        expect(response_data.first['id']).to eq(application_choices.second.id.to_s)
        expect(response_data.second['id']).to eq(application_choices.last.id.to_s)

        expect(response).to have_http_status(:ok)

        get_api_request "/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=2"

        links_object = parsed_response['links']

        expect(links_object['self']).to eq "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=2"
        expect(links_object['prev']).to eq "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=1&per_page=2"
        expect(links_object['next']).to eq "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=&per_page=2"

        expect(parsed_response['data'].first['id']).to eq(application_choices.first.id.to_s)

        expect(response).to have_http_status(:ok)
      end
    end

    it 'returns the first page if no page param is provided' do
      Timecop.freeze(Time.zone.now) do
        create_list(
          :submitted_application_choice,
          3,
          :with_completed_application_form,
          course_option: course_option_for_provider(provider: currently_authenticated_provider),
          status: :awaiting_provider_decision,
        )

        get_api_request "/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=&per_page=2"

        links_object = parsed_response['links']

        expect(links_object['self']).to eq "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=1&per_page=2"
      end
    end

    it 'returns the correct meta data object when paginating' do
      Timecop.freeze(Time.zone.now) do
        create_list(
          :submitted_application_choice,
          10,
          :with_completed_application_form,
          course_option: course_option_for_provider(provider: currently_authenticated_provider),
          status: :awaiting_provider_decision,
        )

        get_api_request "/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&per_page=20"

        expect(response).to have_http_status(:ok)
        expect(parsed_response['meta']['api_version']).to eq 'v1.1'
        expect(parsed_response['meta']['total_count']).to eq 10
        expect(parsed_response['meta']['timestamp']).to eq Time.zone.now.iso8601
      end
    end

    it 'does not paginate when no params are provided' do
      Timecop.freeze(Time.zone.now) do
        create_list(
          :submitted_application_choice,
          10,
          :with_completed_application_form,
          course_option: course_option_for_provider(provider: currently_authenticated_provider),
          status: :awaiting_provider_decision,
        )

        get_api_request "/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

        expect(response).to have_http_status(:ok)
        expect(parsed_response['links']).to include({
          'first' => "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}",
          'last' => "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}",
          'self' => "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}",
          'prev' => "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}",
          'next' => "http://www.example.com/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}",
        })
      end
    end

    it 'returns the correct meta data object when not paginating' do
      Timecop.freeze(Time.zone.now) do
        create_list(
          :submitted_application_choice,
          10,
          :with_completed_application_form,
          course_option: course_option_for_provider(provider: currently_authenticated_provider),
          status: :awaiting_provider_decision,
        )

        get_api_request "/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

        expect(response).to have_http_status(:ok)
        expect(parsed_response['meta']['api_version']).to eq 'v1.1'
        expect(parsed_response['meta']['total_count']).to eq 10
        expect(parsed_response['meta']['timestamp']).to eq Time.zone.now.iso8601
      end
    end

    it 'returns HTTP status 422 when given a parseable page value that exceeds the range' do
      create_list(
        :submitted_application_choice,
        3,
        :with_completed_application_form,
        course_option: course_option_for_provider(provider: currently_authenticated_provider),
        status: :awaiting_provider_decision,
      )

      get_api_request "/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=3&per_page=2"

      expect(response).to have_http_status(:unprocessable_entity)
      expect(error_response['message']).to eql("expected 'page' parameter to be between 1 and 2, got 3")
    end

    it 'returns HTTP status 422 when given a parseable per_page value that exceeds the max value' do
      create_list(
        :submitted_application_choice,
        3,
        :with_completed_application_form,
        course_option: course_option_for_provider(provider: currently_authenticated_provider),
        status: :awaiting_provider_decision,
      )

      max_value = PaginationAPIData::MAX_PER_PAGE
      get_api_request "/api/v1.1/applications?since=#{CGI.escape(1.day.ago.iso8601)}&page=1&per_page=#{max_value + 1}"

      expect(response).to have_http_status(:unprocessable_entity)
      expect(error_response['message']).to eql("the 'per_page' parameter cannot exceed #{max_value} results per page")
    end
  end
end
