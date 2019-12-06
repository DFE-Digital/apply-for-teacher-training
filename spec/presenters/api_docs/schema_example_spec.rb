require 'rails_helper'

RSpec.describe ApiDocs::SchemaExample do
  describe '#as_json' do
    it 'generates an example for an empty schema' do
      example = generate_example({})

      expect(example).to eql({})
    end

    it 'generates examples for an object with strings' do
      example = generate_example(
        properties: {
          name: {
            type: 'string',
          },
        },
      )

      expect(example).to eql(
        'name' => 'string',
      )
    end

    it 'generates examples for an object with integers' do
      example = generate_example(
        properties: {
          id: {
            type: 'integer',
            format: 'int64',
          },
        },
      )

      expect(example).to eql(
        'id' => 'integer',
      )
    end

    it 'generates examples for an object with an object' do
      example = generate_example(
        properties: {
          some_other_thing: {
            type: 'object',
          },
        },
      )

      expect(example).to eql(
        'some_other_thing' => {},
      )
    end

    it 'generates examples for an object with an array' do
      example = generate_example(
        properties: {
          array_of_integers: {
            type: 'array',
            items: {
              type: 'integer',
            },
          },
          array_of_strings: {
            type: 'array',
            items: {
              type: 'string',
            },
          },
        },
      )

      expect(example).to eql(
        'array_of_integers' => %w[integer],
        'array_of_strings' => %w[string],
      )
    end

    def generate_example(schema)
      document = Openapi3Parser.load(
        openapi: '3.0.0',
        info: {
          title: 'Test schema',
          version: '1.0.0',
        },
        paths: {

        },
        components: {
          schemas: {
            SomeSchema: schema,
          },
        },
      )

      ApiDocs::SchemaExample.new(document.components.schemas.first.last).as_json
    end
  end
end
