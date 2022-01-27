RSpec.shared_examples 'a TAD API endpoint' do |path|
  it 'verifies the API token' do
    get_api_request "/data-api/tad-data-exports#{path}", token: nil

    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end
end
