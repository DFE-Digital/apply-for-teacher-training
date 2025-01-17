require 'rails_helper'

RSpec.describe CandidateInterface::SignInCandidateForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }
  end

  describe '#candidate' do
    context 'when no Candidates exist' do
      it 'returns a new Candidate' do
        sign_in = described_class.new(email_address: 'candidate@email.address')

        sign_in_candidate = sign_in.candidate
        expect(sign_in_candidate).to be_a(Candidate)
        expect(sign_in_candidate).to be_new_record
        expect(sign_in_candidate.email_address).to eq('candidate@email.address')
        expect(sign_in_candidate).to be_valid
      end
    end

    context 'when Candidate exists without OneLoginAuth' do
      it 'returns the Candidate' do
        candidate = create(:candidate, email_address: 'candidate@email.address')
        sign_in = described_class.new(email_address: 'candidate@email.address')

        sign_in_candidate = sign_in.candidate
        expect(sign_in_candidate).to eq(candidate)
        expect(sign_in_candidate).to be_valid
      end
    end

    context 'when Candidate exists with a OneLoginAuth with matching email addresses' do
      it 'returns the Candidate' do
        candidate = create(:candidate, email_address: 'one_login@email.address')
        create(:one_login_auth, email_address: 'one_login@email.address', candidate: candidate)

        sign_in = described_class.new(email_address: 'one_login@email.address')

        sign_in_candidate = sign_in.candidate
        expect(sign_in_candidate).to eq(candidate)
        expect(sign_in_candidate).to be_valid
      end
    end

    context 'when Candidate exists with a OneLoginAuth with different email addresses' do
      it 'returns the Candidate' do
        candidate = create(:candidate, email_address: 'candidate@email.address')
        create(:one_login_auth, email_address: 'one_login@email.address', candidate: candidate)

        sign_in = described_class.new(email_address: 'one_login@email.address')

        sign_in_candidate = sign_in.candidate
        expect(sign_in_candidate).to eq(candidate)
        expect(sign_in_candidate).to be_valid
      end
    end

    context 'when Candidate exists with a OneLoginAuth with different email addresses, with old email address' do
      it 'returns a new Candidate with errors' do
        candidate = create(:candidate, email_address: 'candidate@email.address')
        create(:one_login_auth, email_address: 'one_login@email.address', candidate: candidate)

        sign_in = described_class.new(email_address: 'candidate@email.address')

        sign_in_candidate = sign_in.candidate
        expect(sign_in_candidate).not_to eq(candidate)
        expect(sign_in_candidate).to be_new_record
        expect(sign_in_candidate.email_address).to eq('candidate@email.address')
        expect(sign_in_candidate.errors[:email_address]).to include('Not viable for sign-in or sign-up')
      end
    end
  end
end
