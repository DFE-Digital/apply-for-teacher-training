require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/applications/:id/offer', type: :request do
  include VendorApiSpecHelpers

  context 'when a conditional offer is make successfully' do
    let(:application_choice) { create(:application_choice, provider_ucas_code: 'ABC') }
    let(:request_body) do
      {
        "data": {
          "conditions": [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }
    end

    before { post "/api/v1/applications/#{application_choice.id}/offer", params: request_body }

    it 'returns a response that is valid according to the OpenAPI schema' do
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
    end

    it 'returns an application with a conditional offer' do
      expect(parsed_response['data']['attributes']['status']).to eq('conditional_offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
      )
    end
  end

  context 'when an unconditional offer is make successfully' do
    let(:application_choice) { create(:application_choice, provider_ucas_code: 'ABC') }
    let(:request_body) { {} }


    before { post "/api/v1/applications/#{application_choice.id}/offer", params: request_body }

    it 'returns a response that is valid according to the OpenAPI schema' do
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
    end

    it 'returns an application with an unconditional offer' do
      expect(parsed_response['data']['attributes']['status']).to eq('unconditional_offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
       )
    end
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

    post '/api/v1/applications/non-existent-id/offer', params: request_body

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
