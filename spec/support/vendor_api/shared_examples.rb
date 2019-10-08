RSpec.shared_examples 'an endpoint that requires metadata' do |action|
  it 'returns an error when Metadata is not provided' do
    application_choice = create(:application_choice)

    post "/api/v1/applications/#{application_choice.id}/#{action}"

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end

  it 'returns an error when Metadata is invalid' do
    application_choice = create(:application_choice)

    invalid_metadata = { invalid: :metadata }

    post "/api/v1/applications/#{application_choice.id}/#{action}", params: { meta: invalid_metadata }

    error = parsed_response['errors'].first['error']
    error_message = parsed_response['errors'].first['message']

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')

    expect(error).to eq('BadRequestBody')
    expect(error_message).to include("Timestamp can't be blank")
    expect(error_message).to include("Full name can't be blank, Email can't be blank, and User 'user_id' can't be blank")
  end
end
