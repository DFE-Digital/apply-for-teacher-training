require 'rails_helper'

RSpec.describe SupportInterface::ProvidersExport, with_audited: true do
  describe '#providers' do
    it 'returns synced providers and the date they signed the data sharing agreement' do
      create(:provider, sync_courses: false)
      provider_without_signed_dsa = create(:provider, sync_courses: true)
      provider_with_signed_dsa = nil
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
        provider_with_signed_dsa = create(:provider, :with_signed_agreement, sync_courses: true)
      end

      providers = described_class.new.providers
      expect(providers.size).to eq(2)

      expect(providers).to contain_exactly(
        {
          name: provider_with_signed_dsa.name,
          code: provider_with_signed_dsa.code,
          agreement_accepted_at: Time.zone.local(2019, 10, 1, 12, 0, 0),
        },
        {
          name: provider_without_signed_dsa.name,
          code: provider_without_signed_dsa.code,
          agreement_accepted_at: nil,
        },
      )
    end
  end
end
