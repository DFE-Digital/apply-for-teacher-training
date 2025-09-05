module APIDocs
  class SchemaComponent < ApplicationComponent
    include MarkdownHelper

    attr_reader :schema

    def initialize(schema)
      @schema = schema
    end
  end
end
