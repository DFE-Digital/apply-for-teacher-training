require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.1/applications/:application_id/interviews/:interview_id/update', type: :request do
  include VendorAPISpecHelpers

  let(:application_choice) do
    create_application_choice_for_currently_authenticated_provider({}, :with_scheduled_interview)
  end

  let(:interview) { application_choice.interviews.first }

  def post_interview!(params:)
    request_body = { data: params }
    expect(request_body[:data]).to be_valid_against_openapi_schema('UpdateInterview', '1.1')

    post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/#{interview.id}/update", params: request_body
  end

  it_behaves_like 'an endpoint that requires metadata', '/interviews/1/update', '1.1'

  describe 'update interview' do
    context 'in the future' do
      let(:update_interview_params) do
        {
          provider_code: currently_authenticated_provider.code,
          date_and_time: 100.days.from_now.iso8601,
          location: 'Zoom call',
          additional_details: 'Changed details',
        }
      end

      it 'succeeds and renders a SingleApplicationResponse' do
        post_interview! params: update_interview_params

        expect(response).to have_http_status(:ok)
        expect(parsed_response['data']['attributes']['interviews'].first['date_and_time']).to eq(update_interview_params[:date_and_time])
        # expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
      end
    end

    context 'in the past' do
      let(:update_interview_params) do
        {
          provider_code: currently_authenticated_provider.code,
          date_and_time: 1.day.ago.iso8601,
          location: 'Zoom call',
          additional_details: 'This should fail',
        }
      end

      it 'fails and renders an Unprocessable Entity error' do
        skip 'Depends on interview validations work'

        post_interview! params: update_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly("It's not possible to schedule an interview in the past.")
      end
    end

    context 'wrong provider code' do
      let(:update_interview_params) do
        {
          provider_code: create(:provider).code,
          date_and_time: 1.day.from_now.iso8601,
          location: 'Zoom call',
          additional_details: 'This should fail',
        }
      end

      it 'fails and renders an Unprocessable Entity error' do
        skip 'Depends on interview validations work'

        post_interview! params: update_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('Provider code must correspond to training or ratifying provider for the course.')
      end
    end

    context 'wrong api key' do
      let(:update_interview_params) do
        {
          provider_code: provider.code,
          date_and_time: 1.day.from_now.iso8601,
          location: 'Zoom call',
          additional_details: 'This should fail',
        }
      end
      let(:provider) { create(:provider) }
      let(:api_token) { VendorAPIToken.create_with_random_token!(provider: provider) }

      it 'fails and renders an Not Found response' do
        post_interview! params: update_interview_params

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('Unable to find Application(s)')
      end
    end

    context 'when missing parameters' do
      context 'data' do
        it 'fails and renders a MissingParameterResponse' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/create", params: {}

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse', '1.1')
          expect(parsed_response['errors'].map { |error| error['message'] })
            .to contain_exactly('param is missing or the value is empty: data')
        end
      end

      context 'when any data is updated' do
        let(:request_data) do
          {
            data:
            {
              provider_code: currently_authenticated_provider.code,
              location: 'Zoom call',
            },
          }
        end

        it 'is succcesful' do
          skip 'Waiting on interview validations PR to be merged'
          expect(request_data[:data]).to be_valid_against_openapi_schema('UpdateInterview', '1.1')

          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/#{interview.id}/update", params: request_data

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
