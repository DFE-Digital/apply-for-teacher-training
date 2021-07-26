require 'rails_helper'

RSpec.describe CandidateInterface::CreateAccountOrSignInForm, type: :model do
  describe '#validations' do
    it 'validates presence of existing account' do
      form = described_class.new
      expect(form).not_to be_valid
      expect(form.errors.full_messages).to include 'Existing account Select if you already have an account'
    end

    it 'validates presence and format of email if they already have an account' do
      form = described_class.new
      allow(form).to receive(:existing_account).and_return true
      expect(form).not_to be_valid
      expect(form.errors.full_messages).to include 'Email Enter your email address'
      expect(form.errors.full_messages).to include 'Email Enter an email address in the correct format, like name@example.com'
    end
  end

  describe '#existing_account?' do
    it "returns false if existing_account is 'false'" do
      form = described_class.new(existing_account: 'false')
      expect(form.existing_account?).to be false
    end

    it "returns true if existing_account is 'true'" do
      form = described_class.new(existing_account: 'true')
      expect(form.existing_account?).to be true
    end
  end

  describe '#email' do
    context 'when existing_account is true' do
      let(:form) { described_class.new(existing_account: 'true') }

      it 'validates presence' do
        expect(form).not_to be_valid
        form.email = 'rick.roll@email.com'
        expect(form).to be_valid
      end

      it 'validates email address format' do
        form.email = 'rick.roll'
        expect(form).not_to be_valid
        form.email = 'rick.roll@email.com'
        expect(form).to be_valid
      end
    end

    context 'when existing_account is false' do
      let(:form) { described_class.new(existing_account: 'false') }

      it 'is valid without an email' do
        expect(form).to be_valid
      end
    end
  end
end
