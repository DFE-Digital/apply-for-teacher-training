require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/reject' do
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

      post_api_request "/api/v1.0/applications/#{application_choice.id}/reject", params: request_body

      expect(response).to have_http_status(:ok)
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
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
      application_choice = create_application_choice_for_currently_authenticated_provider({}, :offered)

      post_api_request "/api/v1.0/applications/#{application_choice.id}/reject", params: request_body

      expect(response).to have_http_status(:ok)
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
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

    post_api_request "/api/v1.0/applications/#{application_choice.id}/reject", params: request_body

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_response)
      .to contain_schema_with_error('UnprocessableEntityResponse',
                                    "It's not possible to perform this action while the application is in its current state")
  end

  it 'returns an error when a proper reason is not provided' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    post_api_request "/api/v1.0/applications/#{application_choice.id}/reject", params: {
      data: {
        reason: '',
      },
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_response)
      .to contain_schema_with_error('UnprocessableEntityResponse',
                                    'Rejection reason Explain why you are rejecting the application')
  end

  it 'returns not found error when the application was not found' do
    post_api_request '/api/v1.0/applications/non-existent-id/reject', params: {
      data: {
        reason: 'Does not meet minimum GCSE requirements',
      },
    }

    expect(response).to have_http_status(:not_found)
    expect(parsed_response)
      .to contain_schema_with_error('NotFoundResponse', 'Unable to find Applications')
  end

  it 'returns unprocessable error when the payload is malformed' do
    post_api_request '/api/v1.0/applications/non-existent-id/reject', params: {
      data: [],
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_response)
      .to contain_schema_with_error('UnprocessableEntityResponse', 'param is missing or the value is empty or invalid: data')
  end
end
