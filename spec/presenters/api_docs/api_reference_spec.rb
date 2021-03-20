require 'rails_helper'

RSpec.describe APIDocs::APIReference do
  subject :reference do
    described_class.new(spec_definition)
  end

  describe '#operations' do
    let(:spec_definition) do
      OpenAPIExampleSpec.build_with <<~YAML
        paths:
          "/get-a-string":
            get:
              summary: Get a string
              description: This endpoint returns a string
              responses:
                200:
                  description: A string
                  content:
                    application/json:
                      schema:
                        type: string
      YAML
    end

    it 'returns operations' do
      expect(reference.operations.count).to eq 1
      expect(reference.operations.first.name).to eq 'GET /get-a-string'
    end
  end

  describe '#schemas' do
    let(:spec_definition) do
      OpenAPIExampleSpec.build_with <<~YAML
        components:
          schemas:
            Foo:
              type: string
      YAML
    end

    it 'returns schemas' do
      expect(reference.schemas.count).to eq 1
      expect(reference.schemas.first.name).to eq 'Foo'
    end
  end
end
