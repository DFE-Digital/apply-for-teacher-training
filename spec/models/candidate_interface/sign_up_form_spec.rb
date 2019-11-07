require 'rails_helper'

RSpec.describe CandidateInterface::SignUpForm, type: :model do
  let(:valid_email) { Faker::Internet.email }
  let(:invalid_email) { 'invalid_email' }
  let(:given_email) { valid_email }
  let(:candidate) { build_stubbed(:candidate, email_address: given_email) }

  describe '.build_from_candidate' do
    it 'creates an object based on the provided Candidate' do
      form = described_class.build_from_candidate(candidate)
      expect(form).to have_attributes(email_address: valid_email)
    end
  end

  describe '#save_base' do
    let(:accept_ts_and_cs) { true }
    subject do
      described_class.new(  email_address: given_email,
                            accept_ts_and_cs: accept_ts_and_cs )
    end

    context 'when email_address is invalid' do
      let(:given_email) { invalid_email }

      it 'returns false' do
        expect(subject.save_base(candidate))
      end
    end

    context 'when email_address is valid' do
      let(:given_email){ valid_email }

      context 'and accept_ts_and_cs is not present' do
        let(:accept_ts_and_cs) { nil }

        it 'returns false' do
          expect(subject.save_base(candidate)).to eq(false)
        end
      end

      context 'and accept_ts_and_cs is present' do
        let(:accept_ts_and_cs) { true }
        before do
          allow(candidate).to receive(:update!)
                              .and_return true
        end

        it 'updates the candidate model with the given email address' do
          expect(candidate).to receive(:update!).with(email_address: given_email)
          subject.save_base(candidate)
        end

        it 'returns true' do
          expect(subject.save_base(candidate)).to eq(true)
        end
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_ts_and_cs) }
    it { is_expected.to validate_presence_of(:email_address) }

    it { is_expected.to allow_value('test@example.com').for(:email_address) }
    it { is_expected.not_to allow_value('someone').for(:email_address) }
  end
end
