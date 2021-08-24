require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/reject', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/reject'

  describe 'successfully rejecting an application' do
    it 'returns rejected application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        data: {
          reason: 'Does not meet minimum GCSE requirements',
        },
      }

      post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: request_body

      expect(response).to have_http_status(:ok)
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq 'rejected'
      expect(parsed_response['data']['attributes']['rejection']).to match a_hash_including(
        'reason' => 'Does not meet minimum GCSE requirements',
      )
      expect(application_choice.reload.rejection_reason).to eq 'Does not meet minimum GCSE requirements'
      expect(application_choice.reload.rejected_at).to be_present
    end
  end

  describe 'rejecting an application with a decision' do
    let(:request_body) { { data: { reason: 'Course is over-subscribed' } } }

    it 'can reject an already offered application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'offer',
      )

      post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: request_body

      expect(response).to have_http_status(:ok)
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq 'rejected'
      expect(parsed_response['data']['attributes']['rejection']).to match a_hash_including(
        'reason' => 'Course is over-subscribed',
      )
      expect(application_choice.reload.offer_withdrawal_reason).to eq 'Course is over-subscribed'
      expect(application_choice.reload.offer_withdrawn_at).to be_present
    end
  end

  it 'returns an error when trying to transition to an invalid state' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'rejected')
    request_body = {
      data: {
        reason: 'Does not meet minimum GCSE requirements',
      },
    }

    post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: request_body

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
    expect(error_response['message']).to eq 'The application is not ready for that action'
  end

  it 'returns an error when a proper reason is not provided' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: {
      data: {
        reason: '',
      },
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
    expect(error_response['message']).to eql 'Rejection reason Explain why you’re rejecting the application'
  end

  it 'returns not found error when the application was not found' do
    post_api_request '/api/v1/applications/non-existent-id/reject'

    expect(response).to have_http_status(:not_found)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
