require 'rails_helper'

RSpec.describe CandidateInterface::SignUpForm, type: :model do
  let(:valid_email) { Faker::Internet.email }
  let(:new_email) { valid_email }
  let(:existing_candidate) { create(:candidate) }
  let(:existing_email) { existing_candidate.email_address }

  def new_form(email:, accept_ts_and_cs:)
    described_class.new(email_address: email, accept_ts_and_cs: accept_ts_and_cs)
  end

  describe '#save' do
    it 'returns true if it creates a new candidate' do
      form = new_form(email: new_email, accept_ts_and_cs: true)
      expect(form.existing_candidate?).to eq(false)
      expect(form.save).to eq(true)
      expect(form.existing_candidate?).to eq(true)
    end

    it 'returns false if it :accept_ts_and_cs is not true' do
      form = new_form(email: new_email, accept_ts_and_cs: false)
      expect(form.existing_candidate?).to eq(false)
      expect(form.save).to eq(false)
      expect(form.existing_candidate?).to eq(false)
    end

    it 'returns false if it candidate email_address validations fail' do
      form = new_form(email: 'foo', accept_ts_and_cs: false)
      expect(form.existing_candidate?).to eq(false)
      expect(form.save).to eq(false)
      expect(form.errors[:email_address]).not_to be_empty
    end

    it 'returns false if email_address belongs to existing candidate' do
      form = new_form(email: existing_email, accept_ts_and_cs: true)
      expect(form.existing_candidate?).to eq(true)
      expect(form.save).to eq(false)
    end

    it 'returns false if email_address is upcased version of one that exists' do
      form = new_form(email: existing_email.upcase, accept_ts_and_cs: true)
      expect(form.existing_candidate?).to eq(true)
      expect(form.save).to eq(false)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_ts_and_cs) }
    it { is_expected.to validate_presence_of(:email_address) }
  end
end
