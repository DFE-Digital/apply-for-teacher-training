module ApiDocs
  class SchemaExample
    attr_reader :main_schema

    def initialize(main_schema)
      @main_schema = main_schema
    end

    def as_json
      generate_example_from_schema(main_schema)
    end

  private

    def generate_example_from_schema(schema_data)
      properties = {}

      schema_data.properties.each do |key, property|
        properties[key] = property
      end

      properties.merge!(get_all_of_hash(schema_data))

      example_data = {}

      properties.each do |property_key, property|
        example_data[property_key] = generate_example_value_for_property(property)
      end

      example_data
    end

    def generate_example_value_for_property(property)
      if property.example
        property.example
      elsif property.type == 'object'
        if property.items
          generate_example_from_schema(property.items)
        elsif property.properties
          generate_example_from_schema(property)
        else
          {}
        end
      elsif property.type == 'array'
        if property.items
          [generate_example_value_for_property(property.items)]
        else
          []
        end
      else
        # If all else fails, just show the type
        property.type
      end
    end

    def get_all_of_array(schema)
      properties = []

      if schema['allOf']
        schema['allOf'].each do |schema_nested|
          schema_nested.properties.each do |property|
            if property.is_a?(Array)
              property = property[1]
            end

            properties << property
          end
        end
      end

      properties
    end

    def get_all_of_hash(schema)
      properties = {}

      if schema['allOf']
        schema['allOf'].each do |schema_nested|
          schema_nested.properties.each do |key, property|
            properties[key] = property
          end
        end
      end

      properties
    end
  end
end
