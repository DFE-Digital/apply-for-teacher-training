require 'rails_helper'

RSpec.describe SupportInterface::SitesExport do
  describe 'documentation' do
    before do
      provider = create(:provider)
      create(:course_option,
             site_still_valid: true,
             course: create(:course, provider: provider),
             site: create(:site, provider: provider))
    end

    it_behaves_like 'a data export'
  end

  describe '#sites' do
    it 'returns sites and provider details' do
      provider1 = create(:provider, latitude: 20, longitude: 20)
      provider2 = create(:provider, latitude: 20, longitude: 20)

      create(:course_option,
             site_still_valid: true,
             course: create(:course, provider: provider2),
             site: create(:site, latitude: 20, longitude: 21, provider: provider2))

      create(:course_option,
             site_still_valid: true,
             course: create(:course, provider: provider1),
             site: create(:site, latitude: 20, longitude: 21, provider: provider1))

      create(:course_option,
             site_still_valid: false,
             course: create(:course, provider: provider2),
             site: create(:site, latitude: 20, longitude: 21, provider: provider2))

      sites = described_class.new.sites
      expect(sites.size).to eq(2)

      expect(sites).to contain_exactly(
        {
          site_id: provider1.sites.first.id,
          site_code: provider1.sites.first.code,
          provider_code: provider1.code,
          distance_from_provider: '64.9',
        },
        {
          site_id: provider2.sites.first.id,
          site_code: provider2.sites.first.code,
          provider_code: provider2.code,
          distance_from_provider: '64.9',
        },
      )
    end
  end
end
