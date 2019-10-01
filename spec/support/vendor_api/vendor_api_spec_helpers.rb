module VendorApiSpecHelpers
  def parsed_response
    JSON.parse(response.body)
  end

  def error_response
    parsed_response['errors'].first
  end

  def load_openapi_spec(path)
    YAML.load_file(path)
  end

  def transform_openapi_schema_to_json_schema(schema)
    properties = schema['properties']
    schema['properties'] = properties.reduce({}) do |new_props, (prop, value)|
      new_props[prop] = if value['nullable'] == 'true'
                          {
                            'oneOf' => [
                              value.except('nullable'),
                              { 'type' => 'null' },
                            ],
                          }
                        else
                          value
                        end
      new_props
    end

    schema
  end

  def parse_openapi_json_schema(spec, schema_name)
    # Pull up the schema that we want to validate against into the top-level,
    # so that json-schema understands it.
    spec['$schema'] = 'http://json-schema.org/draft-04/schema#'
    spec['$ref'] = "#/components/schemas/#{schema_name}"

    schemas = spec['components']['schemas']
    transformed_schemas = schemas.reduce({}) do |new_schemas, (name, definition)|
      new_schemas[name] = transform_openapi_schema_to_json_schema(definition)
      new_schemas
    end

    spec['components']['schemas'] = transformed_schemas
    spec
  end

  RSpec::Matchers.define :be_valid_against_openapi_schema do |schema_name|
    match do |item|
      schema = parse_openapi_json_schema(
        load_openapi_spec("#{Rails.root}/config/vendor-api-0.4.0.yml"),
        schema_name,
      )

      JSONSchemaValidator.new(
        schema,
        item,
      ).valid?
    end

    failure_message do |item|
      schema = parse_openapi_json_schema(
        load_openapi_spec("#{Rails.root}/config/vendor-api-0.4.0.yml"),
        schema_name,
      )

      JSONSchemaValidator.new(schema, item).failure_message
    end
  end

  class JSONSchemaValidator
    attr_reader :schema, :item

    def initialize(schema, item)
      @schema = schema
      @item = item
    end

    def valid?
      formatted_validation_errors.blank?
    end

    def failure_message
      # @TODO fix this error message so it names the schema
      <<~ERROR
        Expected the item to be valid against schema:

        #{formatted_item}

        But I got these validation errors:

        #{formatted_validation_errors}
      ERROR
    end

  private

    def formatted_validation_errors
      validator = JSON::Validator.fully_validate(schema, item)
      validator.map { |message| '- ' + humanized_error(message) }.join("\n")
    end

    def formatted_item
      return item if item.is_a?(String)

      JSON.pretty_generate(item)
    end

    def humanized_error(message)
      message.gsub("The property '#/'", 'The item')
    end
  end
end
