require 'rails_helper'

RSpec.describe SupportInterface::ActiveProviderUsersExport do
  describe '#call' do
    it 'returns provider_users who have have signd in at least once' do
      provider1 = create(:provider)
      provider2 = create(:provider)
      provider_user1 = create(:provider_user, providers: [provider1], last_signed_in_at: 5.days.ago)
      provider_user2 = create(:provider_user, providers: [provider2], last_signed_in_at: 5.days.ago)
      provider_user3 = create(:provider_user, providers: [provider1, provider2], last_signed_in_at: 5.days.ago)
      create(:provider_user, providers: [provider1])

      expect(described_class.call).to eq([
        {
          name: provider_user1.full_name,
          email_address: provider_user1.email_address,
          providers: provider1.name,
        },
        {
          name: provider_user2.full_name,
          email_address: provider_user2.email_address,
          providers: provider2.name,
        },
        {
          name: provider_user3.full_name,
          email_address: provider_user3.email_address,
          providers: "#{provider1.name}, #{provider2.name}",
        },
      ])
    end
  end
end
