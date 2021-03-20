module APIDocs
  class APISchema
    attr_reader :schema
    delegate :description, :required, to: :schema

    def initialize(name:, schema:)
      @name = name
      @schema = schema
    end

    def properties
      props = []

      if schema['allOf']
        schema['allOf'].each do |schema_nested|
          schema_nested.properties.each do |property|
            props << property
          end
        end
      end

      schema.properties.each do |property|
        props << property
      end

      props.map { |property_name, property_attributes| Property.new(self, property_name, property_attributes) }
    end

    def anchor
      "#{name.parameterize}-object"
    end

    def example
      SchemaExample.new(schema).as_json
    end

    def name
      @name || begin
        referenced_schema_regex = /#\/components\/schemas\//
        location = schema.node_context.source_location.to_s
        if location.match(referenced_schema_regex)
          location.gsub(referenced_schema_regex, '')
        end
      end
    end

    class Property
      attr_reader :schema, :name, :attributes
      delegate :type, :enum, :example, to: :attributes

      def initialize(schema, name, attributes)
        @schema = schema
        @name = name
        @attributes = attributes
      end

      def required?
        name.in?(schema.required.to_a)
      end

      def nullable?
        attributes['nullable']
      end

      def deprecated?
        attributes['deprecated']
      end

      def type_description
        desc = [type]
        desc << ', ISO 8601 date with time and timezone' if attributes.format == 'date-time'
        desc << ', date YYYY-MM-DD' if attributes.format == 'date'

        if type == 'string' && attributes.max_length.present?
          desc << " (limited to #{attributes.max_length} characters)"
        elsif type == 'array' && attributes.max_items.present?
          desc << " (limited to #{attributes.max_items} elements)"
          desc << " of strings (limited to #{attributes.items.max_length} characters)" if limited_string_within_array
        end

        desc.join
      end

      # If the type of the attribute references a schema this returns the name
      def object_schema_name
        linked_schema = attributes

        # If property is an array, check the items property for a reference.
        if type == 'array'
          linked_schema = attributes['items']
        end

        if attributes['anyOf']
          linked_schema = attributes['anyOf'].first
        end

        location = linked_schema.node_context.source_location.to_s

        return if location.match?('/properties')

        location.gsub(/#\/components\/schemas\//, '')
      end

    private

      def limited_string_within_array
        attributes.items.type == 'string' && attributes.items.max_length
      end
    end
  end
end
