module APIDocs
  class APIReference
    attr_reader :document
    delegate :servers, to: :document

    def initialize(spec)
      @document = Openapi3Parser.load(spec)
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
      document.components.schemas.values.map do |schema|
        APISchema.new(schema)
      end
    end

    def field_lengths_summary
      rows = flatten_hash(VendorAPISpecification.as_hash)

      rows.reduce([]) do |arr, (field, length)|
        if field.include?('Length')
          arr << [field.gsub('components.schemas.', ''), length]
        else
          arr
        end
      end
    end

  private

    def flatten_hash(hash)
      hash.each_with_object({}) do |(k, v), h|
        if v.is_a? Hash
          flatten_hash(v).map do |h_k, h_v|
            h["#{k}.#{h_k}"] = h_v
          end
        else
          h[k] = v
        end
      end
    end
  end
end
