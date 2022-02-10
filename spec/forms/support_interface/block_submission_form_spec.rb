require 'rails_helper'

RSpec.describe SupportInterface::BlockSubmissionForm, type: :model do
  let(:duplicate_match) { create(:duplicate_match, candidates: [create(:candidate, submission_blocked: false)]) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_guidance) }
  end

  describe '#save' do
    it 'blocks the candidate from being able to submit' do
      service = described_class.new({ accept_guidance: true })

      expect(service.save(duplicate_match.id)).to be(true)

      expect(duplicate_match.candidates.first.reload.submission_blocked).to be(true)
    end
  end
end
