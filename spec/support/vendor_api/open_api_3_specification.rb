class OpenApi3Specification
  def initialize(open_api_3_spec)
    @spec = open_api_3_spec
  end

  def as_json_schema(schema_name)
    spec = @spec.dup # we do not want to mutate the original schema

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

private

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
end
