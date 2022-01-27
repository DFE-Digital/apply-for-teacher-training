RSpec.shared_examples 'an API endpoint requiring a date param' do |path, date_param, api_token|
  it 'returns an error if the token is incorrect' do
    get "#{path}?#{date_param}=#{CGI.escape(1.day.ago.iso8601)}", headers: { Authorization: 'invalid-token' }

    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it 'returns an error if no API token is present' do
    get "#{path}?#{date_param}=#{CGI.escape(1.day.ago.iso8601)}", headers: { Authorization: nil }

    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse')
  end

  it "returns an error if the #{date_param} parameter is missing" do
    get_api_request path, token: api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('param is missing or the value is empty: updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterInvalidResponse')
  end

  it "returns HTTP status 422 given an unparseable #{date_param} date value" do
    get_api_request "#{path}?#{date_param}=17/07/2020T12:00:42Z", token: api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterInvalidResponse')
  end

  it 'returns HTTP status 422 when encountering a KeyError from ActiveSupport::TimeZone' do
    get_api_request "#{path}?#{date_param}=12936", token: api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('Parameter is invalid (should be ISO8601): updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterInvalidResponse')
  end
end
