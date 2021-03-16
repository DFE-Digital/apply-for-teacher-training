require 'rails_helper'

RSpec.describe SupportInterface::UndoReferenceRefusal do
  describe '#call' do
    it 'reverts a refused reference into the "feedback_requested" state' do
      reference = create(:reference, :feedback_refused)
      described_class.new(reference).call

      expect(reference).to be_feedback_requested
      expect(reference.feedback_refused_at).to eq nil
    end
  end
end
