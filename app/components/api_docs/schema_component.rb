module APIDocs
  class SchemaComponent < ViewComponent::Base
    include MarkdownHelper

    attr_reader :schema

    def initialize(schema)
      @schema = schema
    end
  end
end
