require 'rails_helper'

RSpec.describe APIDocs::APIOperation do
  subject :api_operation do
    # the spec itself is the interface we care about so this
    # is inevitably a bit of an integration test
    reference = APIDocs::APIReference.new(spec)
    reference.operations.first
  end

  let(:response_mime_type) { 'application/json' }

  let :spec do
    OpenAPIExampleSpec.build_with <<~YAML
      paths:
        "/post-a-string":
          post:
            summary: Post a string
            description: This endpoint accepts and returns a string
            requestBody:
              required: true
              content:
                application/json:
                  schema:
                    type: object
                    properties:
                      my_string:
                        type: string
                        example: "I AM A STRING FROM THE CLIENT"
            responses:
              200:
                description: A string
                content:
                  #{response_mime_type}:
                    schema:
                      type: object
                      properties:
                        my_string:
                          type: string
                          example: "I AM A STRING FROM THE API"
              422:
                description: An error
                content:
                  #{response_mime_type}:
                    schema:
                      "$ref": "#/components/schemas/ErrorResponse"
      components:
        schemas:
          ErrorResponse:
            type: object
            properties:
              error_messages:
                type: array
                example: ['Bad word', 'Misspelled']
                items:
                  type: string
    YAML
  end

  describe '#name' do
    it 'renders the HTTP verb plus the name of the path' do
      expect(api_operation.name).to eq 'POST /post-a-string'
    end
  end

  describe '#anchor' do
    it 'renders an identifier suitable for using as an href= anchor' do
      expect(api_operation.anchor).to eq 'post-post-a-string'
    end
  end

  describe '#request_body' do
    it 'provides a schema for the request body' do
      expect(api_operation.request_body.schema.example).to eq('my_string' => 'I AM A STRING FROM THE CLIENT')
      expect(api_operation.request_body.schema.name).to be_nil
    end
  end

  describe '#responses' do
    it 'returns all the responses in a hash' do
      expect(api_operation.responses['200'].schema.example).to eq('my_string' => 'I AM A STRING FROM THE API')
      expect(api_operation.responses['422'].schema.example).to eq('error_messages' => ['Bad word', 'Misspelled'])
    end

    it 'returns a named schema for an referenced schema' do
      expect(api_operation.responses['422'].schema.name).to eq 'ErrorResponse'
    end

    it 'returns an anonymous schema for an inline schema' do
      expect(api_operation.responses['200'].schema.name).to be nil
    end

    it 'returns an application/json mime type' do
      expect(api_operation.responses['200'].mime_type).to eq 'application/json'
    end

    context 'when the response mime type is text/csv' do
      let(:response_mime_type) { 'text/csv' }

      it 'knows the mime type of the response' do
        expect(api_operation.responses['200'].mime_type).to eq 'text/csv'
      end
    end
  end
end
