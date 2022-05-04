require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationDataExportController do
  describe 'export service' do
    it 'is the legacy class when feature flag is disabled' do
      FeatureFlag.deactivate(:data_exports)

      expect(described_class.new.exporter_class).to eq(ProviderInterface::LegacyApplicationDataExport)
    end

    it 'is the standard exporter class when feature flag is disabled' do
      FeatureFlag.activate(:data_exports)

      expect(described_class.new.exporter_class).to eq(ProviderInterface::ApplicationDataExport)
    end
  end
end
