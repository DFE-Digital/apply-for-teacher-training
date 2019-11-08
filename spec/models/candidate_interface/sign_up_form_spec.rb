require 'rails_helper'

RSpec.describe CandidateInterface::SignUpForm, type: :model do
  let(:valid_email) { Faker::Internet.email }
  let(:invalid_email) { 'invalid_email' }

  describe '.build_from_candidate' do
    let(:candidate) { build_stubbed(:candidate, valid_email) }
    it 'creates an object based on the provided Candidate' do
      form = CandidateInterface::SignUpForm.build_from_candidate(candidate)
      expect(form).to have_attributes(email_address: valid_email)
    end
  end

  describe '#save_base' do
    let(:candidate) { build_stubbed(:candidate, given_email) }
    subject{ build(:sign_up_form, accept_ts_and_cs: accept_ts_and_cs) }

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
