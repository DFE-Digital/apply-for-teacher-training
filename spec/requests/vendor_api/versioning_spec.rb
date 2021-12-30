require 'rails_helper'

RSpec.describe 'Versioning', type: :request do
  include VendorAPISpecHelpers

  let(:course) { create(:course, provider: currently_authenticated_provider) }
  let(:course_option) { create(:course_option, course: course) }
  let!(:application_choice) do
    create(:submitted_application_choice,
           :with_completed_application_form,
           :awaiting_provider_decision,
           course_option: course_option)
  end

  before do
    stub_const('VendorAPI::VERSION', '1.2')
  end

  context 'specifying an equivalent minor api version' do
    it 'returns applications' do
      get_api_request "/api/v1.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}"
      expect(parsed_response['data'].size).to eq(1)
    end
  end

  context 'accessing the API with a version that is greater than the current locked version' do
    it 'returns a not found error' do
      stub_const('VendorAPI::VERSIONS', { '1.1' => [VendorAPI::Changes::RetrieveApplications],
                                          '1.101' => [VendorAPI::Changes::RetrieveSingleApplication] })

      get_api_request "/api/v1.101/applications?since=#{CGI.escape(1.day.ago.iso8601)}"
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'accessing a route with a version that is prior to the version that it was introduced in' do
    it 'returns a not found error' do
      stub_const('VendorAPI::VERSIONS', { '1.1' => [VendorAPI::Changes::RetrieveApplications] })

      get_api_request "/api/v1.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}"
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'accessing a route with an invalid version parameter' do
    it 'returns a 404' do
      get_api_request "/api/v1..0/applications?since=#{CGI.escape(1.day.ago.iso8601)}"
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'route validation' do
    context 'when a route is available' do
      context 'when only the major version is specified' do
        it 'processes the route' do
          get_api_request "/api/v1/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:ok)
          expect(parsed_response['data'].size).to eq(1)
        end
      end

      context 'when the full version is specified' do
        it 'processes the route' do
          get_api_request "/api/v1.0/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:ok)
          expect(parsed_response['data'].size).to eq(1)
        end
      end
    end

    context 'when a route is not available for the specified version' do
      it 'returns a not found error' do
        stub_const('VendorAPI::VERSIONS', { '1.2' => [VendorAPI::Changes::RetrieveSingleApplication] })
        get_api_request "/api/v1/applications/#{application_choice.id}"

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when specifying a version after the route was made available' do
      it 'processes the route' do
        stub_const('VendorAPI::VERSIONS', { '1.1' => [VendorAPI::Changes::RetrieveApplications],
                                            '1.2' => [VendorAPI::Changes::RetrieveSingleApplication] })
        get_api_request "/api/v1.2/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

        expect(response.status).to eq(200)
      end
    end
  end
end
