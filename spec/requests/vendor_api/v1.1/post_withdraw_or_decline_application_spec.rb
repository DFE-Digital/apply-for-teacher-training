require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/withdraw' do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/withdraw', '1.1'

  it 'withdraws an application' do
    travel_temporarily_to(Time.zone.now) do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      post_api_request "/api/v1.1/applications/#{application_choice.id}/withdraw"

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')

      expect(response).to have_http_status(:ok)
      application = parsed_response['data']['attributes']
      expect(application['status']).to eq 'withdrawn'
      expect(application['withdrawal']['date'].to_time).to eq Time.zone.now.to_s
      expect(application['withdrawn_or_declined_for_candidate']).to be true
    end
  end

  it 'declines an application' do
    travel_temporarily_to(Time.zone.now) do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'offer',
      )
      create(:offer, application_choice:)

      post_api_request "/api/v1.1/applications/#{application_choice.id}/withdraw"

      expect(response).to have_http_status(:ok)
      application = parsed_response['data']['attributes']
      expect(application['status']).to eq 'declined'
      expect(application['offer']['offer_declined_at'].to_time.to_s).to eq Time.zone.now.to_s
      expect(application['withdrawn_or_declined_for_candidate']).to be true
    end
  end

  it 'returns an UnprocessableEntityResponse when trying to transition to an invalid state' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'withdrawn',
      withdrawn_at: Time.zone.now,
    )

    post_api_request "/api/v1.1/applications/#{application_choice.id}/withdraw"

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_response)
      .to contain_schema_with_error('UnprocessableEntityResponse',
                                    "It's not possible to perform this action while the application is in its current state",
                                    '1.1')
  end

  it 'returns a NotFoundResponse when the application was not found' do
    post_api_request '/api/v1.1/applications/non-existent-id/withdraw'

    expect(response).to have_http_status(:not_found)
    expect(parsed_response).to contain_schema_with_error('NotFoundResponse', 'Unable to find Applications', '1.1')
  end
end
