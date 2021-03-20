module APIDocs
  class APIOperation
    attr_reader :path_name, :operation

    def initialize(http_verb:, path_name:, operation:)
      @http_verb = http_verb
      @path_name = path_name
      @operation = operation
    end

    def name
      "#{@http_verb.upcase} #{path_name}"
    end

    def anchor
      name.parameterize
    end

    def request_body
      DescriptionAndSchema.new(operation.request_body) if operation.request_body
    end

    delegate :summary,
             :description,
             :parameters,
             to: :operation

    def responses
      operation.responses.to_h.transform_values { |response| DescriptionAndSchema.new(response) }
    end
  end

  class DescriptionAndSchema
    attr_reader :definition

    delegate :description, to: :definition

    def initialize(definition)
      @definition = definition
    end

    def schema
      APISchema.new(definition.content['application/json'].schema)
    end
  end
end
