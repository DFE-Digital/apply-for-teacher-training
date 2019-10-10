require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/applications/:application_id/offer', type: :request do
  include VendorApiSpecHelpers

  it_behaves_like 'an endpoint that requires metadata', '/offer'

  describe 'making a conditional offer' do
    it 'returns the updated application' do
      application_choice = create(:application_choice, provider_ucas_code: 'ABC')
      request_body = {
        "data": {
          "conditions": [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('conditional_offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
      )
    end
  end

  describe 'making an unconditional offer' do
    it 'returns the updated application' do
      application_choice = create(:application_choice, provider_ucas_code: 'ABC')

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {}

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('unconditional_offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
      )
    end
  end

  it 'returns an error when trying to transition to an invalid state' do
    application_choice = create(:application_choice, status: 'rejected')

    post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {}

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end

  it 'returns an error when given invalid conditions' do
    application_choice = create(:application_choice, status: 'application_complete')

    post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
      data: {
        conditions: 'DO NOT WANT',
      },
    }

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
    expect(error_response['message']).to eql 'Offer conditions must be an array'
  end

  it 'returns a not found error if the application can\'t be found' do
    request_body = {
                      "data": {
                        "conditions": [
                                  'Completion of subject knowledge enhancement',
                                  'Completion of professional skills test',
                        ],
                      },
                   }

    post_api_request '/api/v1/applications/non-existent-id/offer', params: request_body

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
