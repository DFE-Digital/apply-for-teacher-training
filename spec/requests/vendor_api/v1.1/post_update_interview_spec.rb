require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.1/applications/:application_id/interviews/:interview_id/update' do
  include VendorAPISpecHelpers

  let(:application_choice) do
    create_application_choice_for_currently_authenticated_provider({}, :interviewing)
  end

  let(:interview) { application_choice.interviews.first }
  let(:interview_id) { interview.id }

  def post_interview!(params:, skip_validation: nil)
    request_body = { data: params }
    expect(request_body[:data]).to be_valid_against_openapi_schema('UpdateInterview', '1.1') unless skip_validation

    post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/#{interview_id}/update", params: request_body
  end

  it_behaves_like 'an endpoint that requires metadata', '/interviews/1/update', '1.1'

  describe 'update interview' do
    context 'in the future' do
      let(:update_interview_params) do
        {
          provider_code: currently_authenticated_provider.code,
          date_and_time: 3.days.from_now.iso8601,
          location: 'Zoom call',
          additional_details: 'Changed details',
        }
      end

      it 'succeeds and renders a SingleApplicationResponse' do
        post_interview! params: update_interview_params

        expect(response).to have_http_status(:ok)
        expect(parsed_response['data']['attributes']['interviews'].first['date_and_time']).to eq(update_interview_params[:date_and_time])
        expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
      end
    end

    context 'in the past (ValidationError)' do
      let(:update_interview_params) do
        {
          provider_code: currently_authenticated_provider.code,
          date_and_time: 1.day.ago.iso8601,
          location: 'Zoom call',
          additional_details: 'This should fail',
        }
      end

      it 'fails and renders an UnprocessableEntityResponse' do
        post_interview! params: update_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'Cannot re-schedule interview in the past',
                                                             '1.1')
      end
    end

    context 'a cancelled interview' do
      let(:interview) { create(:interview, :cancelled, application_choice:) }
      let(:update_interview_params) do
        {
          provider_code: currently_authenticated_provider.code,
          date_and_time: 1.day.from_now.iso8601,
          location: 'Zoom call',
          additional_details: 'This should fail because it is a cancelled interview',
        }
      end

      it 'fails and renders an UnprocessableEntityResponse' do
        post_interview! params: update_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response)
          .to contain_schema_with_error('UnprocessableEntityResponse',
                                        'The interview cannot be changed as it has already been cancelled',
                                        '1.1')
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

      it 'fails and renders an UnprocessableEntityResponse' do
        post_interview! params: update_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'Provider must be training or ratifying provider',
                                                             '1.1')
      end
    end

    context 'partial update' do
      let(:update_interview_params) do
        {
          location: 'Brand new location',
        }
      end

      it 'succeeds and preserves other fields' do
        post_interview! params: update_interview_params

        expect(response).to have_http_status(:ok)
        expect(parsed_response['data']['attributes']['interviews'].first['location']).to eq(update_interview_params[:location])
        expect(parsed_response['data']['attributes']['interviews'].first['provider_code']).to eq(interview.provider.code)
      end
    end

    context 'invalid provider code' do
      let(:update_interview_params) do
        {
          provider_code: 'H H',
        }
      end

      it 'fails and renders an UnprocessableEntityResponse' do
        post_interview! params: update_interview_params, skip_validation: true

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'Provider code is not valid',
                                                             '1.1')
      end
    end

    context 'invalid date string' do
      let(:update_interview_params) do
        {
          date_and_time: 'random string',
        }
      end

      it 'fails and renders an UnprocessableEntityResponse' do
        post_interview! params: update_interview_params, skip_validation: true

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'Date string provided is not a valid date',
                                                             '1.1')
      end
    end

    context 'non existent interview id' do
      let(:interview_id) { 'non-existent' }
      let(:update_interview_params) do
        {
          date_and_time: 1.day.from_now.iso8601,
        }
      end

      it 'fails and renders a NotFoundResponse' do
        post_interview! params: update_interview_params, skip_validation: true

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to contain_schema_with_error('NotFoundResponse',
                                                             'Unable to find Interviews',
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
      let(:api_token) { VendorAPIToken.create_with_random_token!(provider:) }

      it 'fails and renders an Not Found response' do
        post_interview! params: update_interview_params

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse', '1.1')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('Unable to find Applications')
      end
    end
  end
end
