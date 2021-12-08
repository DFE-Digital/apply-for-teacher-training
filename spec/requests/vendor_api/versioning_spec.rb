require 'rails_helper'

RSpec.describe 'Versioning', type: :request do
  include VendorAPISpecHelpers

  let(:course) { create(:course, provider: currently_authenticated_provider) }
  let(:course_option) { create(:course_option, course: course) }

  before do
    create(:submitted_application_choice,
           :with_completed_application_form,
           :awaiting_provider_decision,
           course_option: course_option)
  end

  context 'specifying an equivalent minor api version' do
    it 'returns applications' do
      get_api_request "/api/v1.0/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"
      expect(parsed_response['data'].size).to eq(1)
    end
  end

  context 'accessing the API with a minor version that is greater than the current minor version' do
    it 'returns an error' do
      stub_const('VendorAPI::VERSION', '1.2')

      get_api_request "/api/v1.101/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"
      expect(error_response['message']).to eq('Version v1.101 does not exist')
    end
  end

  context 'accessing a route with a version that is prior to the version that it was introduced in' do
    it 'returns an error' do
      stub_const('VendorAPI::ApplicationsController::VERSION', '1.1')

      get_api_request "/api/v1.0/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"
      expect(error_response['message']).to eq('Not available in version v1.0')
    end
  end

  context 'accessing a route with an invalid version parameter' do
    it 'returns a 404' do
      get_api_request "/api/v1..0/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'accessing a route with a patch version specified' do
    it 'returns a 404' do
      get_api_request "/api/v1.0.0/applications?since=#{CGI.escape((Time.zone.now - 1.day).iso8601)}"
      expect(response.status).to eq(404)
    end
  end
end
