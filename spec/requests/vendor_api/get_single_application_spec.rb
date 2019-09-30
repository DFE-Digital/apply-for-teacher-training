require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1/applications/:id', type: :request do
  include VendorApiSpecHelpers

  it 'returns a response that is valid according to the OpenAPI schema' do
    application_choice = create(:application_choice, provider_ucas_code: 'ABC')

    get "/api/v1/applications/#{application_choice.id}"

    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
  end

  it "returns a not found error if the application can't be found" do
    get '/api/v1/applications/asu7dvt87asd'

    expect(response).to have_http_status(404)

    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')

    expect(error_response['message']).to eql('Could not find an application with ID asu7dvt87asd')
  end
end
