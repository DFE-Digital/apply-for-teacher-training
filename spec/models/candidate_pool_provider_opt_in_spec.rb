require 'rails_helper'

RSpec.describe CandidatePoolProviderOptIn do
  describe 'associations' do
    it { is_expected.to belong_to(:provider) }
  end
end
