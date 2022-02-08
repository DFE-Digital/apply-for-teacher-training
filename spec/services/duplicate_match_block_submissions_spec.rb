require 'rails_helper'

RSpec.describe DuplicateMatchBlockSubmissions do
  subject(:block_submissions) { described_class.new.call }

  let(:candidate1) { create(:candidate, email_address: 'exemplar1@example.com') }
  let(:candidate2) { create(:candidate, email_address: 'exemplar2@example.com') }
  let(:candidate3) { create(:candidate, email_address: 'exemplar3@example.com') }

  before do
    Timecop.freeze(Time.zone.local(2022, 1, 28)) do
      create(:fraud_match, candidates: [candidate1, candidate2])
    end

    Timecop.freeze(Time.zone.local(2022, 1, 1)) do
      create(:fraud_match, candidates: [candidate3])
    end

    block_submissions
  end

  context 'when is the right period' do
    it 'marks candidates as submission blocked' do
      expect(candidate1.reload.submission_blocked).to be(true)
      expect(candidate2.reload.submission_blocked).to be(true)
    end
  end

  context 'when is outside of the right period' do
    it 'does not mark candidates as submission blocked' do
      expect(candidate3.reload.submission_blocked).to be(false)
    end
  end
end
