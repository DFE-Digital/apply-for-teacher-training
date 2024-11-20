require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/notes/create' do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  let(:note_payload) { { data: { message: 'Hi hi hi' } } }

  it_behaves_like 'an endpoint that requires metadata', '/notes/create', '1.1'

  it 'creates a new note on the application' do
    application_choice = create_application_choice_for_currently_authenticated_provider

    post_api_request "/api/v1.1/applications/#{application_choice.id}/notes/create", params: note_payload

    expect(response).to have_http_status(:ok)
    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
    notes = parsed_response['data']['attributes']['notes']
    expect(notes.size).to eq(1)
    expect(notes.first['author']).to eq('Jane Smith')
    expect(notes.first['message']).to eq('Hi hi hi')
  end

  it 'responds with 422 when the note data is invalid' do
    application_choice = create_application_choice_for_currently_authenticated_provider

    post_api_request "/api/v1.1/applications/#{application_choice.id}/notes/create", params: { data: { wrong_param: '' } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_response).to contain_schema_with_error('ParameterMissingResponse',
                                                         'param is missing or the value is empty or invalid: message',
                                                         '1.1')
  end

  it 'responds with 404 when the application is not valid for the request' do
    post_api_request "/api/v1.1/applications/#{build_stubbed(:application_choice).id}/notes/create", params: note_payload

    expect(response).to have_http_status(:not_found)
    expect(parsed_response).to contain_schema_with_error('NotFoundResponse',
                                                         'Unable to find Applications',
                                                         '1.1')
  end
end
