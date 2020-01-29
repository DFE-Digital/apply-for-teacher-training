module VendorApi
  class OpenApiSpec
    def self.as_yaml
      spec.to_yaml
    end

    def self.as_hash
      spec
    end

    def self.spec
      if FeatureFlag.active?('experimental_api_features')
        YAML
          .load_file('config/vendor-api-v1.yml')
          .deep_merge(YAML.load_file('config/vendor-api-experimental.yml'))
      else
        YAML.load_file('config/vendor-api-v1.yml')
      end
    end
  end
end
