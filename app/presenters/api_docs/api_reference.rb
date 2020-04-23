module APIDocs
  class APIReference
    attr_reader :document
    delegate :servers, to: :document

    def initialize
      @document = Openapi3Parser.load(VendorAPI::OpenAPISpec.as_hash)
    end

    def operations
      http_operations = document.paths.flat_map do |path_name, path|
        %w[get put post delete patch].map do |http_verb|
          operation = path.public_send(http_verb)
          next unless operation.is_a?(Openapi3Parser::Node::Operation)

          APIDocs::APIOperation.new(http_verb: http_verb, path_name: path_name, operation: operation)
        end
      end

      http_operations.compact
    end

    def schemas
      document.components.schemas.map do |name, schema|
        APISchema.new(name: name, schema: schema)
      end
    end
  end
end
