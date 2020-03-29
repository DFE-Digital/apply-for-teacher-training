require 'rails_helper'

RSpec.describe ProviderOptionsService do
  before do
    @providers = create_list :provider, 5
    @accrediting_providers = create_list :provider, 5
    @provider_user = create :provider_user, providers: [@providers[0], @providers[1]]
    create :course, provider: @providers[0], accrediting_provider: @accrediting_providers[0]
    create :course, provider: @providers[1], accrediting_provider: @accrediting_providers[0]
    create :course, provider: @providers[1], accrediting_provider: @accrediting_providers[1]
    create :course, provider: @providers[2], accrediting_provider: @accrediting_providers[1]
    create :course, provider: @providers[3], accrediting_provider: @accrediting_providers[2]
    create :course, provider: @accrediting_providers[1]
  end

  describe '#accrediting_providers' do
    it 'returns de-duplicated list of only the accrediting providers that the user can access' do
      expect(described_class.new(@provider_user).accrediting_providers).to match_array([
        @accrediting_providers[0],
        @accrediting_providers[1],
      ])
    end

    it 'returns de-duplicated list of only the accrediting providers that the user can access if they are themselves an accrediting provider' do
      accrediting_provider_user = create :provider_user, providers: [@accrediting_providers[1]]
      expect(described_class.new(accrediting_provider_user).accrediting_providers).to match_array([
        @accrediting_providers[1],
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

    it 'returns de-duplicated list of only the providers that the user can access as an accrediting provider' do
      accrediting_provider_user = create :provider_user, providers: [@accrediting_providers[0]]
      expect(described_class.new(accrediting_provider_user).providers).to match_array([
        @providers[0],
        @providers[1],
      ])
    end

    it 'returns de-duplicated list of only the providers that the user can access as an accrediting provider or direct provider' do
      accrediting_provider_user = create :provider_user, providers: [@accrediting_providers[0], @accrediting_providers[1]]
      expect(described_class.new(accrediting_provider_user).providers).to match_array([
        @providers[0],
        @providers[1],
        @providers[2],
        @accrediting_providers[1],
      ])
    end
  end
end
