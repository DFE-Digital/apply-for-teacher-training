require 'rails_helper'

RSpec.describe SupportInterface::SitesExport do
  describe '#sites' do
    it 'returns synced sites and provider details' do
      unsynced_provider = create(:provider, sync_courses: false, latitude: 20, longitude: 20)
      synced_provider = create(:provider, sync_courses: true, latitude: 20, longitude: 20)

      create(:site, latitude: 20, longitude: 21, provider: unsynced_provider)
      create(:site, latitude: 20, longitude: 21, provider: synced_provider)

      sites = described_class.new.sites
      expect(sites.size).to eq(1)

      expect(sites).to contain_exactly(
        {
          'id' => synced_provider.sites.first.id,
          'code' => synced_provider.sites.first.code,
          'provider code' => synced_provider.code,
          'distance from provider' => '64.9',
        },
      )
    end
  end
end
