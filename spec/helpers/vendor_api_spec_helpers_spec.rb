require 'rails_helper'

RSpec.describe VendorApiSpecHelpers do
  subject(:dummy_class) { Class.new { include VendorApiSpecHelpers } }

  it 'maps nullable object properties' do
    spec = {
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
    expect(dummy_class.new.parse_openapi_json_schema(spec, 'ObjectNullable')).to eq expected
  end

  it 'maps nullable object properties within $refs' do
    spec = {
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
    expect(dummy_class.new.parse_openapi_json_schema(spec, 'ObjectWithRefToNullable')).to eq expected
  end
end
