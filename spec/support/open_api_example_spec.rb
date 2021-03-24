class OpenAPIExampleSpec
  BOILERPLATE = <<~YAML
    openapi: '3.0.0'
    info:
      version: 'v1'
    paths: {}
  YAML
  .freeze

  def self.build_with(yaml)
    spec = YAML.safe_load(BOILERPLATE)
    spec.merge(YAML.safe_load(yaml))
  end
end
