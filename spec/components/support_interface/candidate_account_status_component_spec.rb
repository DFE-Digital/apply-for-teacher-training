require 'rails_helper'

RSpec.describe SupportInterface::CandidateAccountStatusComponent do
  subject(:result) do
    render_inline(
      described_class.new(
        candidate_account_status: candidate_account_status,
      ),
    )
  end

  let(:candidate_account_status) do
    SupportInterface::CandidateAccountStatusForm.new(
      candidate: candidate,
    )
  end

  context 'when candidate is unblocked' do
    let(:candidate) { create(:candidate, submission_blocked: false, account_locked: false) }

    it 'renders block account link' do
      expect(result.text).to include('Block account')
    end
  end

  context 'when candidate account access is locked' do
    let(:candidate) { create(:candidate, submission_blocked: false, account_locked: true) }

    it 'renders change status link' do
      expect(result.text).to include('Account access locked')
    end
  end
end
