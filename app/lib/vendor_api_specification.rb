class VendorAPISpecification
  CURRENT_VERSION = '1.0'.freeze

  def initialize(version: nil)
    @version = version || CURRENT_VERSION
  end

  def as_yaml
    spec.to_yaml
  end

  def as_hash
    spec
  end

  def spec
    YAML
      .load_file("config/vendor_api/v#{@version}.yml")
      .deep_merge(YAML.load_file("config/vendor_api/experimental-v#{@version}.yml"))
  end
end
