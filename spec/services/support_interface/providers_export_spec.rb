require 'rails_helper'

RSpec.describe SupportInterface::ProvidersExport, with_audited: true do
  describe 'documentation' do
    before do
      provider = create(:provider, name: 'B', latitude: 51.498161, longitude: 0.129900)
      create(:site, latitude: 51.482578, longitude: -0.007659, provider: provider)
    end

    it_behaves_like 'a data export'
  end

  describe '#providers' do
    it 'returns providers and the date they signed the data sharing agreement' do
      provider_without_signed_dsa = create(:provider, name: 'B', latitude: 51.498161, longitude: 0.129900)
      create(:site, latitude: 51.482578, longitude: -0.007659, provider: provider_without_signed_dsa)
      create(:site, latitude: 52.246868, longitude: 0.711190, provider: provider_without_signed_dsa)

      provider_with_signed_dsa = nil
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
        provider_with_signed_dsa = create(
          :provider,
          :with_signed_agreement,
          name: 'A',
        )
      end

      providers = described_class.new.providers
      expect(providers.size).to eq(2)

      expect(providers).to contain_exactly(
        {
          provider_name: provider_with_signed_dsa.name,
          provider_code: provider_with_signed_dsa.code,
          agreement_accepted_at: Time.zone.local(2019, 10, 1, 12, 0, 0),
          average_distance_to_site: '',
        },
        {
          provider_name: provider_without_signed_dsa.name,
          provider_code: provider_without_signed_dsa.code,
          agreement_accepted_at: nil,
          average_distance_to_site: '31.7',
        },
      )
    end
  end
end
