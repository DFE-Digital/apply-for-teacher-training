RSpec.shared_examples 'an endpoint that requires metadata' do |action|
  it 'returns an error when Metadata is not provided' do
    application_choice = create(:application_choice)

    post "/api/v1/applications/#{application_choice.id}/#{action}", auth_headers

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end

  it 'returns an error when Metadata is invalid' do
    application_choice = create(:application_choice)

    invalid_metadata = { invalid: :metadata }

    post "/api/v1/applications/#{application_choice.id}/#{action}", auth_headers.merge(params: { meta: invalid_metadata })

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')

    errors = parsed_response['errors']

    expect(errors.count).to eq(2)

    expect(errors.map { |e| e['error'] }).to all(eq 'ValidationError')
    expect(errors.map { |e| e['message'] }).to include(
      "timestamp can't be blank",
      "attribution is invalid: full_name can't be blank, email can't be blank, and user_id can't be blank",
    )
  end
end
