require 'rails_helper'

RSpec.describe VendorApi::OpenApiSpec do
  describe '.as_yaml' do
    it 'can roundtrip with the YAML file on disk' do
      yaml_on_disk = File.read('config/vendor-api-v1.yml')

      generated_yaml = VendorApi::OpenApiSpec.as_yaml

      expect(yaml_on_disk).to eq(generated_yaml)
    end
  end

  it 'does not include /experimental paths' do
    advertised_paths = VendorApi::OpenApiSpec.as_hash['paths'].keys
    expect(advertised_paths.filter { |path| path.include?('experimental') }).to be_empty
  end

  context 'when the experimental_api_features flag is on' do
    before { FeatureFlag.activate('experimental_api_features') }

    it 'includes /experimental paths' do
      advertised_paths = VendorApi::OpenApiSpec.as_hash['paths'].keys
      expect(advertised_paths.filter { |path| path.include?('experimental') }).not_to be_empty
    end
  end
end
