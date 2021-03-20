require 'rails_helper'

RSpec.describe APIDocs::APIOperation do
  subject :api_operation do
    # the spec itself is the interface we care about so this
    # is inevitably a bit of an integration test
    reference = APIDocs::APIReference.new(spec)
    reference.operations.first
  end

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
                  application/json:
                    schema:
                      type: object
                      properties:
                        my_string:
                          type: string
                          example: "I AM A STRING FROM THE API"
              422:
                description: An error
                content:
                  application/json:
                    schema:
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
    it 'provides a schema and example for the request body' do
      expect(api_operation.request_body.example).to eq('my_string' => 'I AM A STRING FROM THE CLIENT')
      expect(api_operation.request_body.schema).to be_a APIDocs::APISchema
    end
  end

  describe '#responses' do
    it 'returns all the responses' do
      expect(api_operation.responses.first.code).to eq '200'
      expect(api_operation.responses.first.example).to eq('my_string' => 'I AM A STRING FROM THE API')

      expect(api_operation.responses.second.code).to eq '422'
      expect(api_operation.responses.second.example).to eq('error_messages' => ['Bad word', 'Misspelled'])
    end
  end
end
