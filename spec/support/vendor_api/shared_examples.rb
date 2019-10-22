RSpec.shared_examples 'an endpoint that requires metadata' do |action|
  it 'returns an error when Metadata is not provided' do
    application_choice = create(:application_choice)

    post_api_request "/api/v1/applications/#{application_choice.id}/#{action}", params: { 'meta' => nil }

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end

  it 'returns an error when Metadata is invalid' do
    application_choice = create(:application_choice)

    invalid_metadata = { invalid: :metadata }

    post_api_request "/api/v1/applications/#{application_choice.id}/#{action}", params: { 'meta' => invalid_metadata }

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')

    errors = parsed_response['errors']

    expect(errors.count).to eq(2)

    expect(errors.map { |e| e['error'] }).to all(eq 'ValidationError')
    expect(errors.map { |e| e['message'] }).to include(
      "meta.timestamp can't be blank",
      "meta.attribution is invalid: full_name can't be blank, email can't be blank, and user_id can't be blank",
    )
  end
end
