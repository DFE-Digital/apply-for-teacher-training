require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.1/applications/:application_id/interviews/create', type: :request do
  include VendorAPISpecHelpers

  let(:application_choice) do
    create_application_choice_for_currently_authenticated_provider(status: 'awaiting_provider_decision')
  end

  before do
    stub_const('VendorAPI::VERSION', '1.1')
  end

  def post_interview!(params:)
    request_body = { data: params }
    expect(request_body[:data]).to be_valid_against_openapi_schema('CreateInterview', '1.1')

    post_api_request "/api/v1.1/applications/#{application_choice.id}/interviews/create", params: request_body
  end

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
        # expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
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

      it 'fails and renders an Unprocessable Entity error' do
        skip 'Depends on interview validations work'

        post_interview! params: create_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly("It's not possible to schedule an interview in the past.")
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

      it 'fails and renders an Unprocessable Entity error' do
        skip 'Depends on interview validations work'

        post_interview! params: create_interview_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('Provider code must correspond to training or ratifying provider for the course.')
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
      let(:api_token) { VendorAPIToken.create_with_random_token!(provider: provider) }

      it 'fails and renders an Not Found response' do
        post_interview! params: create_interview_params

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('Unable to find Application(s)')
      end
    end
  end
end
