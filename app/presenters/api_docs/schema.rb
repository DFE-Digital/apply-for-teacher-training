module ApiDocs
  class Schema
    attr_reader :name, :schema
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

    class Property
      attr_reader :schema, :name, :example, :attributes
      delegate :type, to: :attributes

      def initialize(schema, name, attributes)
        @schema = schema
        @name = name
        @attributes = attributes
      end

      def required?
        name.in?(schema.required.to_a)
      end

      def subschema
        linked_schema = attributes

        # If property is an array, check the items property for a reference.
        if type == 'array'
          linked_schema = attributes['items']
        end

        return unless linked_schema.node_context.referenced_by.to_s.include?('#/components/schemas') &&
          !linked_schema.node_context.source_location.to_s.include?('/properties/')

        location = linked_schema.node_context.source_location.to_s
        location.gsub(/#\/components\/schemas\//, '')
      end
    end
  end
end
