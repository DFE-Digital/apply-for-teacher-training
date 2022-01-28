require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.1/applications/:application_id/interviews/:interview_id/cancel', type: :request do
  include VendorAPISpecHelpers

  let(:application_choice) do
    create_application_choice_for_currently_authenticated_provider({}, :with_scheduled_interview)
  end

  let(:interview) { application_choice.interviews.first }

  def post_cancellation!(reason:, skip_schema_check: false)
    request_body = { data: { reason: reason } }
    expect(request_body[:data]).to be_valid_against_openapi_schema('CancelInterview', '1.1') \
      unless skip_schema_check

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
        # expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
      end
    end

    context 'reason too long' do
      it 'fails and renders an Unprocessable Entity error' do
        skip 'Depends on interview validations work'

        post_cancellation! reason: 'A' * 2001, skip_schema_check: true

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('Too long.')
      end
    end

    context 'in the past' do
      it 'fails and renders an Unprocessable Entity error' do
        skip 'Depends on interview validations work'

        application_choice.interviews.first.update_columns(date_and_time: 1.day.ago)

        post_cancellation! reason: 'A reason'

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly("It's not possible to cancel an interview in the past.")
      end
    end

    context 'already cancelled' do
      let(:application_choice) do
        create_application_choice_for_currently_authenticated_provider({}, :with_cancellation_interview)
      end

      it 'fails and renders an Unprocessable Entity error' do
        skip 'Depends on interview validations work'

        post_cancellation! reason: 'A reason'

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly("It's not possible to cancel an interview already cancelled.")
      end
    end

    context 'wrong api key' do
      let(:provider) { create(:provider) }
      let(:api_token) { VendorAPIToken.create_with_random_token!(provider: provider) }

      it 'fails and renders an Not Found response' do
        post_cancellation! reason: 'A reason'

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('Unable to find Application(s)')
      end
    end

    context 'when missing parameters' do
      context 'data' do
        let(:request_data) { { data: {} } }

        it 'fails and renders a MissingParameterResponse' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/#{interview.id}/cancel", params: request_data

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse', '1.1')
          expect(parsed_response['errors'].map { |error| error['message'] })
            .to contain_exactly('param is missing or the value is empty: data')
        end
      end

      context 'cancellation_reason' do
        let(:request_data) do
          { data: { cancellation_reason: nil } }
        end

        it 'fails and renders a MissingParameterResponse' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/#{interview.id}/cancel", params: request_data

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse', '1.1')
          expect(parsed_response['errors'].map { |error| error['message'] })
            .to contain_exactly('param is missing or the value is empty: reason')
        end
      end
    end
  end
end
