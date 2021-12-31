require 'rails_helper'

RSpec.describe SupportInterface::DuplicateCandidateWarningComponent do
  context 'when the candidate is not locked or blocked' do
    it 'renders nothing' do
      result = render_inline described_class.new(candidate: Candidate.new)
      expect(result.text).to be_blank
    end
  end

  context 'when submission_blocked is true' do
    it 'renders a warning message' do
      result = render_inline described_class.new(candidate: Candidate.new(submission_blocked: true))
      expect(result.text).to include('Submission blocked')
    end
  end

  context 'when account_locked and submission_blocked are both true' do
    it 'renders a warning message' do
      result = render_inline described_class.new(candidate: Candidate.new(account_locked: true, submission_blocked: true))
      expect(result.text).to include('Account locked')
    end
  end
end
