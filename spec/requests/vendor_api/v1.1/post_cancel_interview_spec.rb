require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.1/applications/:application_id/interviews/:interview_id/cancel' do
  include VendorAPISpecHelpers

  let(:application_choice) do
    create_application_choice_for_currently_authenticated_provider({}, :interviewing)
  end

  let(:interview) { application_choice.interviews.first }

  def post_cancellation!(reason:, skip_schema_check: false)
    request_body = { data: { reason: } }
    unless skip_schema_check
      expect(request_body[:data]).to be_valid_against_openapi_schema('CancelInterview', '1.1')
    end

    post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/#{interview.id}/cancel", params: request_body
  end

  it_behaves_like 'an endpoint that requires metadata', '/interviews/1/cancel', '1.1'

  describe 'cancel interview' do
    context 'in the future' do
      it 'succeeds and renders a SingleApplicationResponse' do
        post_cancellation! reason: 'A reason'

        expect(response).to have_http_status(:ok)
        expect(parsed_response['data']['attributes']['interviews'].first['cancelled_at']).not_to be_nil
        expect(parsed_response['data']['attributes']['interviews'].first['cancellation_reason']).to eq('A reason')
        expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
      end
    end

    context 'reason too long' do
      it 'fails and renders an UnprocessableEntityResponse' do
        post_cancellation! reason: 'A' * 10241, skip_schema_check: true

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'Cancellation reason must be 10240 characters or fewer',
                                                             '1.1')
      end
    end

    context 'in the past' do
      it 'fails and renders an UnprocessableEntityResponse' do
        application_choice.interviews.first.update_columns(date_and_time: 1.day.ago)

        post_cancellation! reason: 'A reason'

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'The interview cannot be changed as it is in the past',
                                                             '1.1')
      end
    end

    context 'already cancelled' do
      let(:application_choice) do
        create_application_choice_for_currently_authenticated_provider({}, :with_cancelled_interview)
      end

      it 'fails and renders a UnprocessableEntityResponse' do
        post_cancellation! reason: 'A reason'

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'The interview cannot be changed as it has already been cancelled',
                                                             '1.1')
      end
    end

    context 'wrong api key' do
      let(:provider) { create(:provider) }
      let(:api_token) { VendorAPIToken.create_with_random_token!(provider:) }

      it 'fails and renders a NotFoundResponse' do
        post_cancellation! reason: 'A reason'

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to contain_schema_with_error('NotFoundResponse', 'Unable to find Applications', '1.1')
      end
    end

    context 'when missing parameters' do
      context 'data' do
        let(:request_data) { { data: {} } }

        it 'fails and renders a ParameterMissingResponse' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/#{interview.id}/cancel", params: request_data

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response).to contain_schema_with_error('ParameterMissingResponse',
                                                               'param is missing or the value is empty or invalid: data',
                                                               '1.1')
        end
      end

      context 'cancellation_reason' do
        let(:request_data) do
          { data: { cancellation_reason: nil } }
        end

        it 'fails and renders a ParameterMissingResponse' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/#{interview.id}/cancel", params: request_data

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response).to contain_schema_with_error('ParameterMissingResponse',
                                                               'param is missing or the value is empty or invalid: reason',
                                                               '1.1')
        end
      end
    end
  end
end
