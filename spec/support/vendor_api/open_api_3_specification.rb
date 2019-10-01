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
    new_props = {}

    nullable_properties(schema['properties']).each do |prop, value|
      new_props[prop] = {
                          'oneOf' => [
                            value.except('nullable'),
                            { 'type' => 'null' },
                          ],
                        }
    end

    schema['properties'].merge!(new_props)
    schema
  end

  def nullable_properties(props)
    props.select { |_prop, value| value['nullable'] == 'true' }
  end
end
