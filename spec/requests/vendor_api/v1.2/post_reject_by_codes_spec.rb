require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/reject-by-codes' do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/reject-by-codes', '1.2'

  context 'with valid codes and details' do
    let(:application_choice) do
      create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
    end

    it 'responds with a rejected application when given a valid codes and details' do
      request_body = {
        data: [
          {
            code: 'R01',
            details: 'Does not meet minimum GCSE requirements.',
          },
          {
            code: 'R09',
            details: 'Wearing clown shoes to the interview was odd.',
          },
        ],
      }

      post_api_request "/api/v1.2/applications/#{application_choice.id}/reject-by-codes", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.2', draft: false)
      expect(parsed_response['data']['attributes']['status']).to eq 'rejected'
      expect(parsed_response['data']['attributes']['rejection']).to match a_hash_including(
        'reason' => "Qualifications:\nDoes not meet minimum GCSE requirements.\n\nOther:\nWearing clown shoes to the interview was odd.",
      )
      expect(application_choice.reload.structured_rejection_reasons).to eq(
        'selected_reasons' => [
          {
            'id' => 'qualifications',
            'label' => 'Qualifications',
            'details' => {
              'id' => 'qualifications_details',
              'text' => 'Does not meet minimum GCSE requirements.',
            },
          },
          {
            'id' => 'other',
            'label' => 'Other',
            'details' => {
              'id' => 'other_details',
              'text' => 'Wearing clown shoes to the interview was odd.',
            },
          },
        ],
      )
      expect(application_choice.reload.rejected_at).to be_present
      expect(response).to have_http_status(:ok)
    end

    it 'responds with a rejected application when given a single code' do
      request_body = {
        data: [
          {
            code: 'R01',
          },
        ],
      }

      post_api_request "/api/v1.2/applications/#{application_choice.id}/reject-by-codes", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.2', draft: false)
      expect(parsed_response['data']['attributes']['status']).to eq 'rejected'
      expect(parsed_response['data']['attributes']['rejection']).to match a_hash_including(
        'reason' => "Qualifications:\nYou did not have the required or relevant qualifications, or we could not find record of your qualifications.\n",
      )
      expect(application_choice.reload.structured_rejection_reasons).to eq(
        'selected_reasons' => [
          {
            'id' => 'qualifications',
            'label' => 'Qualifications',
            'details' => {
              'id' => 'qualifications_details',
              'text' => "You did not have the required or relevant qualifications, or we could not find record of your qualifications.\n",
            },
          },
        ],
      )
      expect(application_choice.reload.rejected_at).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  context 'with an invalid code' do
    let(:application_choice) do
      create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
    end

    it 'responds with 422' do
      request_body = { data: [{ code: 'hohoho' }] }

      post_api_request "/api/v1.2/applications/#{application_choice.id}/reject-by-codes", params: request_body

      expect(response).to have_http_status(:unprocessable_entity)

      expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse', 'Please provide valid rejection codes.')
    end
  end

  context 'with no codes in payload data' do
    let(:application_choice) do
      create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
    end

    it 'responds with 422' do
      request_body = { data: [] }

      post_api_request "/api/v1.2/applications/#{application_choice.id}/reject-by-codes", params: request_body

      expect(response).to have_http_status(:unprocessable_entity)

      expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse', 'Please provide one or more valid rejection codes.')
    end
  end

  it 'ignores blank `details`' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'awaiting_provider_decision')
    request_body = { data: [{ code: 'R01', details: '' }] }

    post_api_request("/api/v1.2/applications/#{application_choice.id}/reject-by-codes", params: request_body)

    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.2', draft: false)
    expect(parsed_response.dig('data', 'attributes', 'status')).to eq('rejected')
    expect(parsed_response.dig('data', 'attributes', 'rejection', 'reason')).to include('You did not have the required or relevant qualifications')
  end

  it 'returns an error when trying to transition to an invalid state' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'rejected')
    request_body = { data: [{ code: 'R01' }] }

    post_api_request "/api/v1.2/applications/#{application_choice.id}/reject-by-codes", params: request_body

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_response).to contain_schema_with_error(
      'UnprocessableEntityResponse',
      "It's not possible to perform this action while the application is in its current state",
    )
  end

  it 'returns not found error when the application was not found' do
    post_api_request '/api/v1.2/applications/non-existent-id/reject-by-codes'

    expect(response).to have_http_status(:not_found)
    expect(parsed_response).to contain_schema_with_error('NotFoundResponse', 'Unable to find Applications')
  end
end
