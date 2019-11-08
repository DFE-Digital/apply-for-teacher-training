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

  describe '#save' do
    let(:accept_ts_and_cs) { true }
    let(:the_form) do
      described_class.new(email_address: given_email,
                          accept_ts_and_cs: accept_ts_and_cs)
    end

    before do
      allow(candidate).to receive(:update!)
    end

    context 'when email_address is invalid' do
      let(:given_email) { invalid_email }

      it 'returns false' do
        expect(the_form.save(candidate)).to eq(false)
      end

      it 'does not update the candidate model' do
        the_form.save(candidate)
        expect(candidate).not_to have_received(:update!)
      end
    end

    context 'when email_address is valid and accept_ts_and_cs is not present' do
      let(:given_email) { valid_email }
      let(:accept_ts_and_cs) { nil }

      it 'returns false' do
        expect(the_form.save(candidate)).to eq(false)
      end

      it 'does not update the candidate model' do
        the_form.save(candidate)
        expect(candidate).not_to have_received(:update!)
      end
    end

    context 'when email_address is valid and accept_ts_and_cs is present' do
      let(:given_email) { valid_email }
      let(:accept_ts_and_cs) { true }

      before do
        allow(candidate).to receive(:update!)
                            .and_return true
      end

      it 'updates the candidate model with the given email address' do
        the_form.save(candidate)
        expect(candidate).to have_received(:update!).with(email_address: given_email)
      end

      it 'returns true' do
        expect(the_form.save(candidate)).to eq(true)
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
