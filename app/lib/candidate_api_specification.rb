class CandidateAPISpecification
  CURRENT_VERSION = 'v1.4'.freeze
  VERSIONS = %w[v1.1 v1.2 v1.3 v1.4].freeze

  def self.as_yaml(version = CURRENT_VERSION)
    spec(version).to_yaml
  end

  def self.as_hash(version = CURRENT_VERSION)
    spec(version)
  end

  def self.spec(version = CURRENT_VERSION)
    YAML.load_file("config/candidate_api/#{version}.yml", permitted_classes: [Time])
  end
end
