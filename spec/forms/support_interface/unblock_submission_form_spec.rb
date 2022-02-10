require 'rails_helper'

RSpec.describe SupportInterface::UnblockSubmissionForm, type: :model do
  let(:duplicate_match) { create(:duplicate_match, candidates: [create(:candidate, submission_blocked: true)]) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_guidance) }
  end

  describe '#save' do
    it 'unblocks the candidate after being blocked' do
      service = described_class.new({ accept_guidance: true })

      expect(service.save(duplicate_match.id)).to be(true)

      expect(duplicate_match.candidates.first.reload.submission_blocked).to be(false)
    end
  end
end
