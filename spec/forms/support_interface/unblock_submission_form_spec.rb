require 'rails_helper'

RSpec.describe SupportInterface::UnblockSubmissionForm, type: :model do
  let(:fraud_match) { create(:fraud_match, candidates: [create(:candidate, submission_blocked: true)]) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_guidance) }
  end

  describe '#save' do
    it 'unblocks the candidate after being blocked' do
      service = described_class.new({ accept_guidance: true })

      expect(service.save(fraud_match.id)).to be(true)

      expect(fraud_match.candidates.first.reload.submission_blocked).to be(false)
    end
  end
end
