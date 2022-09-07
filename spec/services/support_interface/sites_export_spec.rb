require 'rails_helper'

RSpec.describe SupportInterface::SitesExport do
  describe 'documentation' do
    before do
      provider = create(:provider)
      create(:course_option,
             site_still_valid: true,
             course: create(:course, provider:),
             site: create(:site, provider:))
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

      site1 = provider1.sites.first
      site2 = provider2.sites.first
      expect(sites).to contain_exactly(
        {
          site_id: site1.id,
          site_code: site1.code,
          provider_code: provider1.code,
          distance_from_provider: '64.9',
          site_uuid: site1.uuid,
          recruitment_cycle_year: site1.course_options.first.course.recruitment_cycle_year,
        },
        {
          site_id: site2.id,
          site_code: site2.code,
          provider_code: provider2.code,
          distance_from_provider: '64.9',
          site_uuid: site2.uuid,
          recruitment_cycle_year: site2.course_options.first.course.recruitment_cycle_year,
        },
      )
    end
  end
end
