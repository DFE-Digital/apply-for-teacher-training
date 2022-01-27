class VendorAPISpecification
  include VersioningHelpers

  SPEC_FILE_DIR = 'config/vendor_api'.freeze
  DRAFT_YAML_FILE_PATH = "#{SPEC_FILE_DIR}/draft.yml".freeze

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
    (0..minor_version_number(@version)).each_with_object({}) do |minor_version, versions|
      version_to_load = "#{major_version_number(@version)}.#{minor_version}"

      if File.exist?(yaml_file_path(version_to_load))
        yaml_for_version = YAML.load_file(yaml_file_path(version_to_load))

        merge_experimental_spec!(yaml_for_version, version_to_load)
      end

      merge_draft_spec!(yaml_for_version)

      versions.deep_merge!(yaml_for_version) if yaml_for_version.present?
    end
  end

private

  def yaml_file_path(version_to_load)
    "#{SPEC_FILE_DIR}/v#{version_to_load}.yml"
  end

  def merge_experimental_spec!(yaml_for_version, version_to_load)
    experimental_yaml_file_for_version = "#{SPEC_FILE_DIR}/experimental-v#{version_to_load}.yml"

    if File.exist?(experimental_yaml_file_for_version)
      yaml_for_version.deep_merge!(YAML.load_file(experimental_yaml_file_for_version))
    end

    yaml_for_version
  end

  def merge_draft_spec!(yaml_for_version)
    if draft? && File.exist?(DRAFT_YAML_FILE_PATH)
      yaml_for_version.deep_merge!(YAML.load_file(DRAFT_YAML_FILE_PATH))
    end

    yaml_for_version
  end

  def draft?
    @draft == true
  end
end
