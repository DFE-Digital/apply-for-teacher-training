require 'rails_helper'

RSpec.describe DfESignInUser, type: :model do
  describe '.load_from_session' do
    it 'returns the DfE User when the user has signed in and has been recently active' do
      session = { 'dfe_sign_in_user' => { 'last_active_at' => Time.zone.now } }

      user = DfESignInUser.load_from_session(session)

      expect(user).not_to be_nil
    end

    it 'returns nil when the user has signed in and has not been recently active' do
      session = { 'dfe_sign_in_user' => { 'last_active_at' => Time.zone.now - 1.day } }

      user = DfESignInUser.load_from_session(session)

      expect(user).to be_nil
    end

    it 'returns nil when the user has not signed in' do
      session = { 'dfe_sign_in_user' => nil }

      user = DfESignInUser.load_from_session(session)

      expect(user).to be_nil
    end

    it 'returns nil when the user does not have a last active timestamp' do
      session = { 'dfe_sign_in_user' => { 'last_active_at' => nil } }

      user = DfESignInUser.load_from_session(session)

      expect(user).to be_nil
    end
  end
end
