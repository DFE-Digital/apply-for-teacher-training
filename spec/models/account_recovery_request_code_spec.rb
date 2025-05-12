require 'rails_helper'

RSpec.describe AccountRecoveryRequestCode do
  describe 'associations' do
    it { is_expected.to belong_to(:account_recovery_request) }
  end

  it { is_expected.to have_secure_password(:code) }

  describe 'validations' do
    it { is_expected.to validate_presence_of :code }
  end

  context 'scodes' do
    describe 'not_expired' do
      it 'returns codes that are not expired' do
        valid_code = create(:account_recovery_request_code)
        create(:account_recovery_request_code, created_at: 2.hours.ago)

        expect(described_class.not_expired).to eq([valid_code])
      end
    end
  end

  describe '.generate_code' do
    it 'generates a 6 character code' do
      expect(described_class.generate_code.size).to eq(6)
    end
  end
end
