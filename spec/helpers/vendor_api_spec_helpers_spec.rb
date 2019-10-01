require 'rails_helper'

RSpec.describe VendorApiSpecHelpers do
  subject(:dummy_class) { Class.new { include VendorApiSpecHelpers } }

  it 'works' do
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
end
