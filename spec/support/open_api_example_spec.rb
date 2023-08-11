class OpenAPIExampleSpec
  def self.build_with(yaml)
    spec = YAML.safe_load(OPEN_API_YAML_BOILERPLATE)
    spec.merge(YAML.safe_load(yaml))
  end
end
