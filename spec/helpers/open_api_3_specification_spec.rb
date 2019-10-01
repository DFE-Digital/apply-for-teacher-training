require 'rails_helper'

RSpec.describe OpenApi3Specification do
  subject(:spec) { OpenApi3Specification.new(spec_definition) }

  describe '#as_json_schema' do
    context 'when the schema is an object and has a nullable property' do
      let(:spec_definition) do
        {
          'components' => {
            'schemas' => {
              'ObjectNullable' => {
                'type' => 'object',
                'properties' => {
                  'nullableProperty' => {
                    'anyOf' => [
                      { 'type' => 'string' },
                    ],
                    'nullable' => 'true',
                  },
                },
              },
            },
          },
        }
      end

      it 'transforms the nullable property into valid JSON schema' do
        expected = {
          '$ref' => '#/components/schemas/ObjectNullable',
          '$schema' => 'http://json-schema.org/draft-04/schema#',
          'components' => {
            'schemas' => {
              'ObjectNullable' => {
                'type' => 'object',
                'properties' => {
                  'nullableProperty' => {
                    'oneOf' => [
                      {
                        'anyOf' => [
                          { 'type' => 'string' },
                        ],
                      },
                      { 'type' => 'null' },
                    ],
                  },
                },
              },
            },
          },
        }

        expect(spec.as_json_schema('ObjectNullable')).to eq expected
      end
    end

    context 'when the requested schema references another schema with a nullable property' do
      let(:spec_definition) do
        {
          'components' => {
            'schemas' => {
              'ObjectWithRefToNullable' => {
                'type' => 'object',
                'properties' => {
                  'myNullableObject' => {
                    '$ref' => '#/components/schemas/ObjectNullable',
                  },
                },
              },
              'ObjectNullable' => {
                'type' => 'object',
                'properties' => {
                  'nullableProperty' => {
                    'anyOf' => [
                      { 'type' => 'string' },
                    ],
                    'nullable' => 'true',
                  },
                },
              },
            },
          },
        }
      end

      it 'transforms the nullable property of the referenced schema into valid JSON schema' do
        expected = {
          '$ref' => '#/components/schemas/ObjectWithRefToNullable',
          '$schema' => 'http://json-schema.org/draft-04/schema#',
          'components' => {
            'schemas' => {
              'ObjectWithRefToNullable' => {
                'type' => 'object',
                'properties' => {
                  'myNullableObject' => {
                    '$ref' => '#/components/schemas/ObjectNullable',
                  },
                },
              },
              'ObjectNullable' => {
                'type' => 'object',
                'properties' => {
                  'nullableProperty' => {
                    'oneOf' => [
                      {
                        'anyOf' => [
                          { 'type' => 'string' },
                        ],
                      },
                      { 'type' => 'null' },
                    ],
                  },
                },
              },
            },
          },
        }
        expect(spec.as_json_schema('ObjectWithRefToNullable')).to eq expected
      end
    end
  end
end
