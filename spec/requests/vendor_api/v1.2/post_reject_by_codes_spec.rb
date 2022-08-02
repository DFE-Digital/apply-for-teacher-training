require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/reject-by-codes', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/reject-by-codes', '1.2'

  describe 'making a request to /reject-by-codes' do
    let(:application_choice) do
      create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
    end

    it 'returns no content' do
      request_body = {
        data: [
          {
            code: '01',
            details: 'Does not meet minimum GCSE requirements',
          },
        ],
      }

      post_api_request "/api/v1.2/applications/#{application_choice.id}/reject-by-codes", params: request_body

      expect(response).to have_http_status(:no_content)
    end
  end
end
