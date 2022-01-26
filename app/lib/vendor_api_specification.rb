class VendorAPISpecification
  include VersioningHelpers

  YAML_FILE_PATH = 'config/vendor_api'.freeze
  DRAFT_YAML_FILE_PATH = "#{YAML_FILE_PATH}/draft.yml".freeze

  def initialize(version: nil, draft: false)
    @version = version || VendorAPI::VERSION
    @draft = draft
  end

  def as_yaml
    spec.to_yaml
  end

  def as_hash
    spec
  end

  def spec
    (0..minor_version_number(@version)).inject({}) do |versions, minor_version|
      version_to_load = "#{major_version_number(@version)}.#{minor_version}"

      yaml_file_for_version = "#{YAML_FILE_PATH}/v#{version_to_load}.yml"

      if File.exist?(yaml_file_for_version)
        yaml_for_version = YAML.load_file(yaml_file_for_version)

        experimental_yaml_file_for_version = "#{YAML_FILE_PATH}/experimental-v#{version_to_load}.yml"

        if File.exist?(experimental_yaml_file_for_version)
          yaml_for_version = yaml_for_version.deep_merge(YAML.load_file(experimental_yaml_file_for_version))
        end

      end

      if draft? && File.exist?(DRAFT_YAML_FILE_PATH)
        yaml_for_version = yaml_for_version.deep_merge(YAML.load_file(DRAFT_YAML_FILE_PATH))
      end

      versions = versions.deep_merge(yaml_for_version) if yaml_for_version.present?

      versions
    end
  end

  def draft?
    @draft == true
  end
end
