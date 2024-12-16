require 'rails_helper'

RSpec.describe OneLoginUserBypass do
  describe 'validations' do
    subject { described_class.new(token: 'token') }

    it { is_expected.to validate_presence_of :token }
  end

  describe 'authentificate' do
    subject(:authentificate) { described_class.new(token: 'token').authentificate }

    it 'returns the candidate with existing token' do
      candidate = create(:candidate)
      create(:one_login_auth, candidate:, token: 'token')

      expect { authentificate }.to not_change(
        candidate.reload.one_login_auth,
        :id,
      )

      expect(authentificate).to eq(candidate)
    end

    it 'creates a with one login auth if candidate does not exist' do
      expect { authentificate }.to change(
        Candidate,
        :count,
      ).by(1)

      expect(authentificate).to eq(Candidate.last)
      expect(authentificate.one_login_auth).to have_attributes(
        email_address: authentificate.email_address,
        token: 'token',
      )
    end
  end
end
