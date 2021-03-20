require 'rails_helper'

RSpec.describe APIDocs::OperationComponent do
  describe 'linking to the schema of the response object we return' do
    let :spec_with_schema_reference do
      OpenAPIExampleSpec.build_with <<~YAML
        paths:
          "/post-a-string":
            post:
              responses:
                422:
                  description: An error
                  content:
                    application/json:
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

    let :spec_without_schema_reference do
      OpenAPIExampleSpec.build_with <<~YAML
        paths:
          "/post-a-string":
            post:
              responses:
                422:
                  description: An error
                  content:
                    application/json:
                      schema:
                        type: string
      YAML
    end

    it 'links when the schema refers to a named object' do
      operation = APIDocs::APIReference.new(spec_with_schema_reference).operations.first

      result = render_inline described_class.new(operation)

      expect(result.text).to include 'This request will return a ErrorResponse object'
    end

    it 'doesn’t link when the schema is inline' do
      operation = APIDocs::APIReference.new(spec_without_schema_reference).operations.first

      result = render_inline described_class.new(operation)

      expect(result.text).not_to include 'This request will return'
    end
  end
end
