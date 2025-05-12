require 'rails_helper'

RSpec.describe OneLoginUserBypass do
  describe 'validations' do
    subject(:one_login_user_bypass) { described_class.new(token:) }

    let(:token) { 'token' }

    it { is_expected.to validate_presence_of :token }

    context 'when token is invalid' do
      let(:token) { 'token@email.com' }

      it 'returns token invalid if token is email address' do
        expect(one_login_user_bypass).not_to be_valid
      end
    end
  end

  describe 'authenticate' do
    subject(:authenticate) { described_class.new(token:).authenticate }

    let(:token) { 'dev-candidate' }

    it 'returns the candidate with existing token dev-candidate' do
      candidate = create(:candidate)
      create(:one_login_auth, candidate:, token: 'dev-candidate')

      expect(authenticate).to eq(candidate)
    end

    context 'when token is not dev-candidate' do
      let(:token) { 'token' }

      it 'returns the nil if token is not dev-candidate' do
        candidate = create(:candidate)
        create(:one_login_auth, candidate:, token: 'dev-candidate')

        expect(authenticate).to be_nil
      end
    end
  end
end
