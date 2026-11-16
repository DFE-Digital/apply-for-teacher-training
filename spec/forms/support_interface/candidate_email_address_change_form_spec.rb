require 'rails_helper'

RSpec.describe SupportInterface::CandidateEmailAddressChangeForm, type: :model do
  let(:candidate_1) { create(:candidate, email_address: 'bob_smith@example.com') }
  let(:candidate_2) { create(:candidate, email_address: 'alice_jones@example.com', account_locked: true) }
  let(:match) { create(:duplicate_match, candidates: [candidate_1, candidate_2]) }

  describe 'validations' do
    subject(:form) { described_class.new }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_presence_of(:candidate_id) }
    it { is_expected.to validate_presence_of(:match_id) }

    context 'when email_address is "other"' do
      subject(:form) { described_class.new(email_address: 'other', candidate_id: candidate_1.id, match_id: match.id) }

      it { is_expected.to validate_presence_of(:other_email_address) }
    end

    context 'when the other_email_address is already linked to another active account' do
      subject(:form) do
        described_class.new(
          email_address: 'other',
          other_email_address: create(:candidate).email_address,
          candidate_id: candidate_1.id,
          match_id: match.id,
        )
      end

      it 'adds an error to the other_email_address attribute' do
        expect(form.valid?).to be_falsey
        expect(form.errors[:other_email_address]).to include('This email address is already linked to another active account.')
      end
    end
  end

  describe '#update!' do
    context 'when a candidate exists for the given email address' do
      let(:form) do
        described_class.new(email_address: candidate_2.email_address, candidate_id: candidate_1.id, match_id: match.id)
      end

      it 'swaps the email addresses of the two candidates' do
        expect { form.update! }.to change { candidate_1.reload.email_address }.from(candidate_1.email_address).to(candidate_2.email_address)
          .and change { candidate_2.reload.email_address }.from(candidate_2.email_address).to(candidate_1.email_address)
      end
    end

    context 'when the candidate exists, and is in the duplicate match, for the given other email address' do
      let(:form) do
        described_class.new(email_address: 'other', other_email_address: candidate_2.email_address, candidate_id: candidate_1.id, match_id: match.id)
      end

      it 'swaps the email addresses of the two candidates' do
        expect { form.update! }.to change { candidate_1.reload.email_address }.from(candidate_1.email_address).to(candidate_2.email_address)
          .and change { candidate_2.reload.email_address }.from(candidate_2.email_address).to(candidate_1.email_address)
      end
    end

    context 'when no candidate exists for the given other email address' do
      let(:form) do
        described_class.new(
          email_address: 'other',
          other_email_address: 'new_email_address@example.com',
          candidate_id: candidate_1.id,
          match_id: match.id,
        )
      end

      it 'updates the candidate email address to the given other email address' do
        expect { form.update! }.to change { candidate_1.reload.email_address }.from(candidate_1.email_address).to('new_email_address@example.com')
      end
    end

    context 'when the other email address is already linked to another (unmatched) active account' do
      let(:form) do
        described_class.new(
          email_address: 'other',
          other_email_address: create(:candidate).email_address,
          candidate_id: candidate_1.id,
          match_id: match.id,
        )
      end

      it 'returns false' do
        expect(form.update!).to be_falsey
      end
    end

    context 'when the other email address is already linked to another (matched) active account' do
      let(:candidate_2) { create(:candidate, email_address: 'alice_jones@example.com') }
      let(:form) do
        described_class.new(
          email_address: 'other',
          other_email_address: candidate_2.email_address,
          candidate_id: candidate_1.id,
          match_id: match.id,
        )
      end

      it 'returns false' do
        expect(form.update!).to be_falsey
      end
    end
  end
end
