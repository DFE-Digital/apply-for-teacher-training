module ApiDocs
  class ApiReference
    attr_reader :document
    delegate :servers, to: :document

    def initialize
      @document = Openapi3Parser.load_file('config/vendor-api-0.8.0.yml')
    end

    def operations
      http_operations = document.paths.flat_map do |path_name, path|
        %w[get put post delete patch].map do |http_verb|
          operation = path.public_send(http_verb)
          next unless operation.is_a?(Openapi3Parser::Node::Operation)

          ApiDocs::ApiOperation.new(http_verb: http_verb, path_name: path_name, operation: operation)
        end
      end

      http_operations.compact
    end

    def schemas
      document.components.schemas.map do |name, schema|
        ApiSchema.new(name: name, schema: schema)
      end
    end
  end
end
