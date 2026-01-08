module APIDocs
  class SchemaComponent < BaseComponent
    include MarkdownHelper

    attr_reader :schema

    def initialize(schema)
      @schema = schema
    end
  end
end
