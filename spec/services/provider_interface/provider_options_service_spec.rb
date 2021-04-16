require 'rails_helper'

RSpec.describe ProviderInterface::ProviderOptionsService do
  before do
    @sites = [create(:site), create(:site)]
    @providers = create_list :provider, 5
    @accredited_providers = create_list :provider, 5
    @provider_user = create :provider_user, providers: [@providers[0], @providers[1]]
    create :course, provider: @providers[0], accredited_provider: @accredited_providers[0]
    create :course, provider: @providers[1], accredited_provider: @accredited_providers[0]
    create :course, provider: @providers[1], accredited_provider: @accredited_providers[1]
    create :course, provider: @providers[2], accredited_provider: @accredited_providers[1]
    create :course, provider: @providers[3], accredited_provider: @accredited_providers[2]
    create :course, provider: @accredited_providers[1]
  end

  describe '#accredited_providers' do
    it 'returns de-duplicated list of only the accredited providers that the user can access' do
      expect(described_class.new(@provider_user).accredited_providers).to match_array([
        @accredited_providers[0],
        @accredited_providers[1],
      ])
    end

    it 'returns de-duplicated list of only the accredited providers that the user can access if they are themselves an accredited provider' do
      accredited_provider_user = create :provider_user, providers: [@accredited_providers[1]]
      expect(described_class.new(accredited_provider_user).accredited_providers).to match_array([
        @accredited_providers[1],
      ])
    end
  end

  describe '#providers' do
    it 'returns de-duplicated list of only the providers that the user can access' do
      expect(described_class.new(@provider_user).providers).to match_array([
        @providers[0],
        @providers[1],
      ])
    end

    it 'returns de-duplicated list of only the providers that the user can access as an accredited provider' do
      accredited_provider_user = create :provider_user, providers: [@accredited_providers[0]]
      expect(described_class.new(accredited_provider_user).providers).to match_array([
        @providers[0],
        @providers[1],
      ])
    end

    it 'returns de-duplicated list of only the providers that the user can access as an accredited provider or direct provider' do
      accredited_provider_user = create :provider_user, providers: [@accredited_providers[0], @accredited_providers[1]]
      expect(described_class.new(accredited_provider_user).providers).to match_array([
        @providers[0],
        @providers[1],
        @providers[2],
        @accredited_providers[1],
      ])
    end
  end

  describe '#providers_with_manageable_users' do
    let(:provider_user) { create(:provider_user, providers: @providers) }

    before { provider_user.provider_permissions.find_by(provider: @providers.last).update(manage_users: true) }

    it 'returns providers with users manageable by the provider user' do
      expect(described_class.new(provider_user).providers_with_manageable_users).to eq([@providers.last])
    end
  end

  describe '#providers_with_sites' do
    it 'returns providers with sites' do
      @provider_user.providers.first.update(sites: @sites)

      providers = described_class.new(@provider_user).providers_with_sites(provider_ids: @provider_user.providers.first.id)

      expect(providers.first.association(:sites).loaded?).to eq(true)
      expect(providers.first.sites).to match_array(@sites)
    end
  end
end
