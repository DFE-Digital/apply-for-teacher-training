require 'rails_helper'

RSpec.describe VendorAPI::OpenAPISpec do
  describe '.as_yaml' do
    it 'includes /experimental paths' do
      advertised_paths = VendorAPI::OpenAPISpec.as_hash['paths'].keys
      expect(advertised_paths.filter { |path| path.include?('experimental') }).not_to be_empty
    end
  end
end
