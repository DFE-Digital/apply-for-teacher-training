require 'rails_helper'

RSpec.describe VendorApi::OpenApiSpec do
  describe '.as_yaml' do
    it 'includes /experimental paths' do
      advertised_paths = VendorApi::OpenApiSpec.as_hash['paths'].keys
      expect(advertised_paths.filter { |path| path.include?('experimental') }).not_to be_empty
    end
  end
end
