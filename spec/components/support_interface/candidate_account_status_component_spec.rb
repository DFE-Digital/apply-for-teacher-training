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

  context 'when duplicate matching feature flag is active' do
    before do
      FeatureFlag.activate(:duplicate_matching)
    end

    context 'when candidate is unblocked' do
      let(:candidate) { create(:candidate, submission_blocked: false, account_locked: false) }

      it 'renders block account link' do
        expect(result.text).to include('Block Account')
      end
    end

    context 'when candidate account access is locked' do
      let(:candidate) { create(:candidate, submission_blocked: false, account_locked: true) }

      it 'renders change status link' do
        expect(result.text).to include('Account access locked')
      end
    end
  end

  context 'when duplicate matching feature flag is inactive' do
    let(:candidate) { build(:candidate) }

    before do
      FeatureFlag.deactivate(:duplicate_matching)
    end

    it 'does not render' do
      expect(result.text).to eq('')
    end
  end
end
