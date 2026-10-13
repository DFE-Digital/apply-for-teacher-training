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
    yaml_for_version = versions_up_to_load.each_with_object({}) do |version_to_load, versions|
      version_yaml = version_yaml_for(version_to_load)
      versions.deep_merge!(version_yaml) if version_yaml.present?
    end

    if draft?
      merge_draft_spec(yaml_for_version)
    else
      yaml_for_version
    end
  end

private

  def versions_up_to_load
    requested = Gem::Version.new(full_version_number_from(@version))

    ordered_versions.keys.select { |version| Gem::Version.new(version) <= requested }
  end

  def version_yaml_for(version_to_load)
    return unless File.exist?(yaml_file_path(version_to_load))

    version_yaml = YAML.load_file(yaml_file_path(version_to_load), permitted_classes: [Time, Date])
    merge_experimental_spec(version_yaml, version_to_load)
  end

  def yaml_file_path(version_to_load)
    "#{SPEC_FILE_DIR}/v#{version_to_load}.yml"
  end

  def merge_experimental_spec(yaml_for_version, version_to_load)
    experimental_yaml_file_for_version = "#{SPEC_FILE_DIR}/experimental-v#{version_to_load}.yml"

    if File.exist?(experimental_yaml_file_for_version)
      yaml_for_version.deep_merge(YAML.load_file(experimental_yaml_file_for_version))
    else
      yaml_for_version
    end
  end

  def merge_draft_spec(yaml_for_version)
    return nil if yaml_for_version.blank?

    if File.exist?(DRAFT_YAML_FILE_PATH)
      yaml_for_version.deep_merge(YAML.load_file(DRAFT_YAML_FILE_PATH))
    else
      yaml_for_version
    end
  end

  def draft?
    @draft == true
  end
end
