class DataAPISpecification
  def self.as_yaml
    spec.to_yaml
  end

  def self.as_hash
    spec
  end

  def self.spec
    openapi = YAML.load_file('config/data-api.yml')

    dataset = DataSetDocumentation.for(DataAPI::TADExport)

    openapi['components']['schemas']['TADCSVSchema']['properties'] = dataset

    openapi
  end
end
