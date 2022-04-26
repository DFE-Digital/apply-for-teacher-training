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

    context 'when specifying a version change without an action' do
      let(:application_choice) { create_application_choice_for_currently_authenticated_provider }
      let(:note_payload) { { data: { message: Faker::Lorem.sentence } } }

      it 'the route is processed' do
        stub_const('VendorAPI::VERSIONS', { '1.0' => [VendorAPI::Changes::RetrieveApplications],
                                            '1.1' => [VendorAPI::Changes::AddNotesToApplication,
                                                      VendorAPI::Changes::CreateNote,
                                                      VendorAPI::Changes::AddMetaToApplication] })
        post_api_request "/api/v1.1/applications/#{application_choice.id}/notes/create", params: note_payload

        expect(response.status).to eq(200)
      end
    end

    context 'a prerelease version' do
      before do
        stub_const('VendorAPI::VERSIONS', { '1.1' => [VendorAPI::Changes::RetrieveApplications],
                                            '1.2pre' => [VendorAPI::Changes::RetrieveSingleApplication] })
      end

      context 'when it doesnt match the VERSION constant' do
        before do
          stub_const('VendorAPI::VERSION', '1.1')
        end

        it 'is not available in sandbox' do
          allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(true)

          get_api_request "/api/v1.2/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:not_found)
        end

        it 'is not available in production' do
          allow(HostingEnvironment).to receive(:environment_name).and_return('production')

          get_api_request "/api/v1.2/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:not_found)
        end

        it 'is available in all other environments' do
          get_api_request "/api/v1.2/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:ok)
        end
      end

      context 'when it matches the VERSION constant' do
        before do
          stub_const('VendorAPI::VERSION', '1.2')
        end

        it 'is available in sandbox' do
          allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(true)

          get_api_request "/api/v1.2/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:ok)
        end

        it 'is not available in production' do
          allow(HostingEnvironment).to receive(:environment_name).and_return('production')

          get_api_request "/api/v1.2/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:not_found)
        end

        it 'is available in all other environments' do
          get_api_request "/api/v1.2/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'a released version' do
      before do
        stub_const('VendorAPI::VERSIONS', { '1.1' => [VendorAPI::Changes::RetrieveApplications],
                                            '1.2' => [VendorAPI::Changes::RetrieveSingleApplication] })
      end

      context 'when it matches the VERSION constant' do
        before do
          stub_const('VendorAPI::VERSION', '1.2')
        end

        it 'is available in sandbox' do
          allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(true)

          get_api_request "/api/v1.2/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:ok)
        end

        it 'is available in production' do
          allow(HostingEnvironment).to receive(:environment_name).and_return('production')

          get_api_request "/api/v1.2/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'a version that has not been defined' do
      before do
        stub_const('VendorAPI::VERSIONS', { '1.1' => [VendorAPI::Changes::RetrieveApplications],
                                            '1.2pre' => [VendorAPI::Changes::RetrieveSingleApplication] })
        stub_const('VendorAPI::VERSION', '1.1')
      end

      it 'is not available regardless the environment' do
        get_api_request "/api/v1.3/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
