require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.7/applications/:application_id/interviews/create' do
  include VendorAPISpecHelpers

  let(:application_choice) do
    create_application_choice_for_currently_authenticated_provider(status: 'awaiting_provider_decision')
  end

  def post_interview!(params:)
    request_body = { data: params }
    expect(request_body[:data]).to be_valid_against_openapi_schema('CreateInterview', '1.7') if params.present?

    post_api_request "/api/v1.7/applications/#{application_choice.id}/interviews/create", params: request_body
  end

  it_behaves_like 'an endpoint that requires metadata', '/interviews/create', '1.7'

  describe 'create interview' do
    context 'when passed interview params' do
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
        expect(parsed_response['data']['attributes']['status']).to eq('awaiting_provider_decision')
        application_choice.reload
        expect(application_choice.status).to eq('interviewing')
      end
    end

    context 'when not passed interview params' do
      it 'succeeds and renders a SingleApplicationResponse' do
        post_interview! params: {}

        expect(response).to have_http_status(:ok)
        expect(parsed_response['data']['attributes']['interviews'].count).to eq(0)
        expect(parsed_response['data']['attributes']['status']).to eq('awaiting_provider_decision')
        application_choice.reload
        expect(application_choice.status).to eq('interviewing')
      end
    end
  end
end
