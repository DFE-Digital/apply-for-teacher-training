require 'rails_helper'

RSpec.describe VendorApi::OpenApiSpec do
  describe '.as_yaml' do
    it 'can roundtrip with the YAML file on disk' do
      yaml_on_disk = File.read('config/vendor-api-v1.yml')

      generated_yaml = VendorApi::OpenApiSpec.as_yaml

      expect(yaml_on_disk).to eq(generated_yaml)
    end
  end
end
