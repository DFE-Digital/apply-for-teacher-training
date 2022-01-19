require 'rails_helper'

RSpec.describe SupportInterface::CandidateAccountStatusForm, type: :model do
  subject(:candidate_account_status) do
    described_class.new(attributes.merge(candidate: candidate))
  end

  let(:attributes) { {} }

  describe '#status' do
    context 'when account status is not locked or blocked' do
      let(:candidate) { create(:candidate, submission_blocked: false, account_locked: false) }

      it 'returns the unblocked text' do
        expect(candidate_account_status.status).to eq('unblocked')
      end
    end

    context 'when account status is locked' do
      let(:candidate) { create(:candidate, submission_blocked: false, account_locked: true) }

      it 'returns the account locked text' do
        expect(candidate_account_status.status).to eq('account_access_locked')
      end
    end

    context 'when account status is blocked' do
      let(:candidate) { create(:candidate, submission_blocked: true, account_locked: false) }

      it 'returns the account submission blocked' do
        expect(candidate_account_status.status).to eq('account_submission_blocked')
      end
    end

    context 'when account status is set' do
      let(:candidate) { create(:candidate, submission_blocked: false, account_locked: false) }
      let(:attributes) { { status: 'account_submission_blocked' } }

      it 'returns the account submission blocked' do
        expect(candidate_account_status.status).to eq('account_submission_blocked')
      end
    end
  end

  describe '#unblocked?' do
    context 'when submission is blocked' do
      let(:candidate) { create(:candidate, submission_blocked: true) }

      it 'returns false' do
        expect(candidate_account_status).not_to be_unblocked
      end
    end

    context 'when account access is locked' do
      let(:candidate) { create(:candidate, account_locked: true) }

      it 'returns false' do
        expect(candidate_account_status).not_to be_unblocked
      end
    end

    context 'when unblocked' do
      let(:candidate) { create(:candidate, submission_blocked: false, account_locked: false) }

      it 'returns true' do
        expect(candidate_account_status).to be_unblocked
      end
    end
  end

  describe '#update!' do
    subject(:record) do
      candidate.reload
    end

    before do
      candidate_account_status.update!
    end

    context 'when blocking submission' do
      let(:candidate) { create(:candidate, submission_blocked: false, account_locked: false) }
      let(:attributes) { { status: 'account_submission_blocked' } }

      it 'flags as submission blocked' do
        expect(record.submission_blocked?).to be_truthy
      end

      it 'unlocking the account access' do
        expect(record.account_locked?).to be_falsey
      end
    end

    context 'when locking an account' do
      let(:candidate) { create(:candidate, submission_blocked: false, account_locked: false) }
      let(:attributes) { { status: 'account_access_locked' } }

      it 'unblocks submission' do
        expect(record.submission_blocked?).to be_falsey
      end

      it 'flags as account locked' do
        expect(record.account_locked?).to be_truthy
      end
    end

    context 'when unblocking an account' do
      let(:candidate) { create(:candidate, submission_blocked: true, account_locked: true) }
      let(:attributes) { { status: 'unblocked' } }

      it 'unblocks submission' do
        expect(record.submission_blocked?).to be_falsey
      end

      it 'unlocks account' do
        expect(record.account_locked?).to be_falsey
      end
    end
  end
end
