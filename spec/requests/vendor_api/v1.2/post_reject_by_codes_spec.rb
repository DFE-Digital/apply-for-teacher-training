require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/reject-by-codes', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/reject-by-codes', '1.2'

  describe 'with valid codes and details' do
    let(:application_choice) do
      create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
    end

    it 'responds with a rejected application' do
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

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.2')
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
  end
end
