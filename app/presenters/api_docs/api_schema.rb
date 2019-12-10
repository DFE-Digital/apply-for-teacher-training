module ApiDocs
  class ApiSchema
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

    def anchor
      "#{name.parameterize}-object"
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
    end
  end
end
