require 'rails_helper'

RSpec.describe VendorAPISpecification do
  describe '.as_yaml' do
    it 'includes /test-data paths' do
      advertised_paths = described_class.new.as_hash['paths'].keys
      expect(advertised_paths.filter { |path| path.include?('test-data') }).not_to be_empty
    end
  end

  describe 'minor versions' do
    it 'merges the minor version paths into the major version spec' do
      major_version_paths = described_class.new(version: '1.0').as_hash['paths'].keys
      minor_version_paths = described_class.new(version: '1.1').as_hash['paths'].keys

      expect(minor_version_paths).to include(*major_version_paths)
      expect(minor_version_paths).to include('/applications/{application_id}/notes/create')
    end

    it 'merges the minor version components into the major version spec' do
      major_version_components = described_class.new(version: '1.0').as_hash['components']
      minor_version_components = described_class.new(version: '1.1').as_hash['components']

      major_version_components.each_key do |key|
        expect(minor_version_components[key].keys).to include(*major_version_components[key].keys)
      end

      expect(minor_version_components['schemas']).to include('CreateNote')
    end
  end

  describe 'draft specs' do
    it 'loads and merges the draft spec file' do
      allow(YAML).to receive(:load_file).with(anything).and_call_original

      major_version_paths = described_class.new(version: '1.0').as_hash['paths'].keys
      draft_version_paths = described_class.new(draft: true).as_hash['paths'].keys

      expect(YAML).to have_received(:load_file).with('config/vendor_api/draft.yml')

      expect(draft_version_paths).to include(*major_version_paths)
    end
  end
end
