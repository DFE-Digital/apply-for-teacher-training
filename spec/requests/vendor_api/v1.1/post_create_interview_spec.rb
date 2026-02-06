require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.1/applications/:application_id/interviews/create' do
  include VendorAPISpecHelpers

  let(:application_choice) do
    create_application_choice_for_currently_authenticated_provider(status: 'awaiting_provider_decision')
  end

  def post_interview!(params:)
    request_body = { data: params }
    expect(request_body[:data]).to be_valid_against_openapi_schema('CreateInterview', '1.1')

    post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/create", params: request_body
  end

  it_behaves_like 'an endpoint that requires metadata', '/interviews/create', '1.1'

  describe 'create interview' do
    context 'in the future' do
      let(:create_interview_params) do
        {
          provider_code: currently_authenticated_provider.code,
          date_and_time: 1.day.from_now.iso8601,
          location: 'Zoom call',
          additional_details: 'Candidate requires assistance',
        }
      end

      it 'succeeds and renders a SingleApplicationResponse' do
        post_interview! params: create_interview_params

        expect(response).to have_http_status(:ok)
        expect(parsed_response['data']['attributes']['interviews'].count).to eq(1)
        expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
      end
    end

    context 'in the past' do
      let(:create_interview_params) do
        {
          provider_code: currently_authenticated_provider.code,
          date_and_time: 1.day.ago.iso8601,
          location: 'Zoom call',
          additional_details: 'This should fail',
        }
      end

      it 'fails and renders an UnprocessableEntityResponse' do
        post_interview! params: create_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'Cannot schedule interview in the past',
                                                             '1.1')
      end
    end

    context 'wrong provider code' do
      let(:create_interview_params) do
        {
          provider_code: create(:provider).code,
          date_and_time: 1.day.from_now.iso8601,
          location: 'Zoom call',
          additional_details: 'This should fail',
        }
      end

      it 'fails and renders an UnprocessableEntityResponse' do
        post_interview! params: create_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'Provider must be training or ratifying provider',
                                                             '1.1')
      end
    end

    context 'application not in an interviewing state' do
      let(:application_choice) do
        create_application_choice_for_currently_authenticated_provider(status: 'offer')
      end

      let(:create_interview_params) do
        {
          provider_code: currently_authenticated_provider.code,
          date_and_time: 1.day.from_now.iso8601,
          location: 'Zoom call',
          additional_details: 'This should fail because of the application',
        }
      end

      it 'fails and renders an UnprocessableEntityResponse' do
        post_interview! params: create_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'Application is not in an interviewing state',
                                                             '1.1')
      end
    end

    context 'wrong api key' do
      let(:create_interview_params) do
        {
          provider_code: provider.code,
          date_and_time: 1.day.from_now.iso8601,
          location: 'Zoom call',
          additional_details: 'This should fail',
        }
      end
      let(:provider) { create(:provider) }
      let(:api_token) { VendorAPIToken.create_with_random_token!(provider:) }

      it 'fails and renders a NotFoundResponse' do
        post_interview! params: create_interview_params

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to contain_schema_with_error('NotFoundResponse',
                                                             'Unable to find Applications',
                                                             '1.1')
      end
    end

    context 'when missing parameters' do
      context 'data' do
        it 'fails and renders a ParameterMissingResponse' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/create", params: {}

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response).to contain_schema_with_error('ParameterMissingResponse',
                                                               'param is missing or the value is empty or invalid: data',
                                                               '1.1')
        end
      end

      context 'date_and_time' do
        let(:interview_params) do
          {
            provider_code: currently_authenticated_provider.code,
            location: 'Zoom call',
            additional_details: 'This should fail',
          }
        end

        it 'fails and renders a ParameterMissingResponse' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/create", params: { data: interview_params }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response).to contain_schema_with_error('ParameterMissingResponse',
                                                               'param is missing or the value is empty or invalid: date_and_time',
                                                               '1.1')
        end
      end

      context 'provider_code' do
        let(:interview_params) do
          {
            location: 'Zoom call',
            date_and_time: 1.day.from_now.iso8601,
            additional_details: 'This should fail',
          }
        end

        it 'fails and renders a ParameterMissingResponse' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/create", params: { data: interview_params }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response).to contain_schema_with_error('ParameterMissingResponse',
                                                               'param is missing or the value is empty or invalid: provider_code',
                                                               '1.1')
        end
      end

      context 'location' do
        let(:interview_params) do
          {
            provider_code: currently_authenticated_provider.code,
            date_and_time: 1.day.from_now.iso8601,
            additional_details: 'This should fail',
          }
        end

        it 'fails and renders a ParameterMissingResponse' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/create", params: { data: interview_params }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response).to contain_schema_with_error('ParameterMissingResponse',
                                                               'param is missing or the value is empty or invalid: location',
                                                               '1.1')
        end
      end

      context 'additional_details' do
        let(:request_data) do
          { data:
            {
              provider_code: currently_authenticated_provider.code,
              date_and_time: 1.day.from_now.iso8601,
              location: 'Zoom call',
            } }
        end

        it 'is succcesful' do
          expect(request_data[:data]).to be_valid_against_openapi_schema('CreateInterview', '1.1')

          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/create", params: request_data

          expect(response).to have_http_status(:ok)
          expect(parsed_response['data']['attributes']['interviews'].count).to eq(1)
        end
      end
    end
  end
end
