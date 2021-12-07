module APIDocs
  class APIOperation
    attr_reader :path_name, :operation, :new_path

    def initialize(http_verb:, path_name:, operation:, new_path: nil)
      @http_verb = http_verb
      @path_name = path_name
      @operation = operation
      @new_path = new_path
    end

    def name
      if @new_path
        "#{@http_verb.upcase} #{path_name} 🆕"
      else
        "#{@http_verb.upcase} #{path_name}"
      end
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
      APIDocs::APISchema.new(definition.content[mime_type].schema)
    end

    def mime_type
      definition.content.keys.first
    end
  end
end
