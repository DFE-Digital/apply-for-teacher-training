require 'rails_helper'

RSpec.describe Pool::Candidates do
  describe '.for_provider' do
    it 'returns candidates who have not been dismissed by the provider' do
      provider = create(:provider)
      opt_in_candidate = create(:candidate, pool_status: 'opt_in')
      _opt_out_candidate = create(:candidate, pool_status: 'opt_out')
      invited_candidate = create(:candidate, pool_status: 'opt_in')
      dismissed_candidate = create(:candidate, pool_status: 'opt_in')

      create(:pool_invite, provider: provider, candidate: invited_candidate)
      create(:pool_dismissal, provider: provider, candidate: dismissed_candidate)

      candidates = described_class.for_provider(provider: provider)

      expect(candidates).to contain_exactly(opt_in_candidate, invited_candidate)
      opt_in_pool_candidate = candidates.to_a.find { |c| c.id == opt_in_candidate.id }
      invited_pool_candidate = candidates.to_a.find { |c| c.id == invited_candidate.id }
      expect(opt_in_pool_candidate).not_to be_invited
      expect(invited_pool_candidate).to be_invited
    end
  end
end
