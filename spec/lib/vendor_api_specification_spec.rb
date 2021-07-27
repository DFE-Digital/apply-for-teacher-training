require 'rails_helper'

RSpec.describe VendorAPISpecification do
  describe '.as_yaml' do
    it 'includes /test-data paths' do
      advertised_paths = described_class.as_hash['paths'].keys
      expect(advertised_paths.filter { |path| path.include?('test-data') }).not_to be_empty
    end
  end
end
