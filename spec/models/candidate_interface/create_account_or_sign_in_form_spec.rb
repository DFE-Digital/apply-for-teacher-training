require 'rails_helper'

RSpec.describe CandidateInterface::CreateAccountOrSignInForm, type: :model do
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
end
