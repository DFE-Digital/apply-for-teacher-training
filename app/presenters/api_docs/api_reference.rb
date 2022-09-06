module APIDocs
  class APIReference
    include Rails.application.routes.url_helpers

    attr_reader :document
    delegate :servers, to: :document

    def initialize(spec, version: nil, draft: false)
      @document = Openapi3Parser.load(spec)
      @version = version || AllowedCrossNamespaceUsage::VendorAPIInfo.production_version
      @draft = draft
    end

    def operations
      http_operations = document.paths.flat_map do |path_name, path|
        %w[get put post delete patch].map do |http_verb|
          operation = path.public_send(http_verb)
          next unless operation.is_a?(Openapi3Parser::Node::Operation)

          APIDocs::APIOperation.new(http_verb:, path_name:, operation:, new_path: new_path?(path_name))
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
      rows = flatten_hash(VendorAPISpecification.new(version: @version, draft: @draft).as_hash)

      rows.reduce([]) do |arr, (field, length)|
        if field.include?('Length')
          arr << [field.gsub('components.schemas.', ''), length]
        else
          arr
        end
      end
    end

    def self.draft_schema
      @draft_schema ||= YAML.load_file(VendorAPISpecification::DRAFT_YAML_FILE_PATH)
    end

    def self.current_schema
      path = "#{VendorAPISpecification::SPEC_FILE_DIR}/v#{AllowedCrossNamespaceUsage::VendorAPIInfo.production_version}.yml"
      @current_schema ||= YAML.load_file(path, permitted_classes: [Time])
    end

    def api_docs_version_navigation_items
      AllowedCrossNamespaceUsage::VendorAPIInfo.released_versions.keys.map do |version|
        { name: version.to_s, url: api_docs_versioned_reference_path(api_version: "v#{version}") }
      end
    end

    def render_api_docs_version_navigation?
      api_docs_version_navigation_items.size > 1
    end

  private

    def draft?
      @draft == true
    end

    def new_path?(path)
      return false unless draft?
      return false unless draft_schema_file_exists?

      draft_schema_paths.include?(path) && current_schema_paths.exclude?(path)
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

    def draft_schema_paths
      self.class.draft_schema['paths']
    end

    def current_schema_paths
      self.class.current_schema['paths']
    end

    def draft_schema_file_exists?
      @draft_schema_file_exists ||= File.exist?(VendorAPISpecification::DRAFT_YAML_FILE_PATH)
    end
  end
end
