module APIDocs
  class APIReference
    attr_reader :document
    delegate :servers, to: :document

    def initialize(spec, version: nil)
      @document = Openapi3Parser.load(spec)
      @version = version || AllowedCrossNamespaceUsage::VENDOR_API_VERSION
    end

    def operations
      http_operations = document.paths.flat_map do |path_name, path|
        %w[get put post delete patch].map do |http_verb|
          operation = path.public_send(http_verb)
          next unless operation.is_a?(Openapi3Parser::Node::Operation)

          APIDocs::APIOperation.new(http_verb: http_verb, path_name: path_name, operation: operation, new_path: new_path?(path_name))
        end
      end

      http_operations.compact
    end

    def schemas
      document.components.schemas.values.map do |schema|
        APIDocs::APISchema.new(schema)
      end
    end

    def field_lengths_summary
      rows = flatten_hash(VendorAPISpecification.new(version: @version).as_hash)

      rows.reduce([]) do |arr, (field, length)|
        if field.include?('Length')
          arr << [field.gsub('components.schemas.', ''), length]
        else
          arr
        end
      end
    end

  private

    def new_path?(path)
      return false unless draft_schema_file_exists?

      draft_schema['paths'].include?(path) && current_schema['paths'].exclude?(path)
    end

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

    def draft_schema
      @draft_schema ||= YAML.load_file(draft_yaml_file_path)
    end

    def draft_schema_file_exists?
      @draft_schema_file_exists ||= File.exist?(draft_yaml_file_path)
    end

    def draft_yaml_file_path
      VendorAPISpecification::DRAFT_YAML_FILE_PATH
    end

    def current_schema
      @current_schema ||= YAML.load_file("#{VendorAPISpecification::SPEC_FILE_DIR}/v#{@version}.yml")
    end
  end
end
