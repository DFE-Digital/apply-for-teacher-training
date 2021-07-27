require 'rails_helper'

RSpec.describe DfESignInUser, type: :model do
  describe '.load_from_session' do
    it 'returns the DfE User when the user has signed in and has been recently active' do
      session = { 'dfe_sign_in_user' => { 'last_active_at' => Time.zone.now } }

      user = described_class.load_from_session(session)

      expect(user).not_to be_nil
    end

    it 'returns nil when the user has signed in and has not been recently active' do
      session = { 'dfe_sign_in_user' => { 'last_active_at' => Time.zone.now - 1.day } }

      user = described_class.load_from_session(session)

      expect(user).to be_nil
    end

    it 'returns nil when the user has not signed in' do
      session = { 'dfe_sign_in_user' => nil }

      user = described_class.load_from_session(session)

      expect(user).to be_nil
    end

    it 'returns nil when the user does not have a last active timestamp' do
      session = { 'dfe_sign_in_user' => { 'last_active_at' => nil } }

      user = described_class.load_from_session(session)

      expect(user).to be_nil
    end

    it 'may return a DfE User with an associated impersonated_provider_user' do
      provider_user = create(:provider_user)

      session = {
        'dfe_sign_in_user' => { 'last_active_at' => Time.zone.now },
        'impersonated_provider_user' => { 'provider_user_id' => provider_user.id },
      }
      user = described_class.load_from_session(session)
      expect(user.impersonated_provider_user).to eq(provider_user)

      session = { 'dfe_sign_in_user' => { 'last_active_at' => Time.zone.now } }
      user = described_class.load_from_session(session)
      expect(user.impersonated_provider_user).to be_nil
    end
  end

  describe '#begin_impersonation!' do
    let(:provider_user) { create(:provider_user) }
    let(:dsi_user) do
      described_class.new(email_address: nil, dfe_sign_in_uid: nil, first_name: nil, last_name: nil)
    end

    it 'adds an impersonated_provider_user section to the session' do
      session = {}
      dsi_user.begin_impersonation! session, provider_user
      expect(session).to have_key('impersonated_provider_user')
    end

    it 'stores the impersonated provider user id' do
      session = {}
      dsi_user.begin_impersonation! session, provider_user
      expect(session['impersonated_provider_user']['provider_user_id']).to eq(provider_user.id)
    end
  end

  describe '#end_impersonation!' do
    let(:dsi_user) do
      described_class.new(email_address: nil, dfe_sign_in_uid: nil, first_name: nil, last_name: nil)
    end

    it 'deletes the impersonated_provider_user section' do
      session = { 'impersonated_provider_user' => {} }
      dsi_user.end_impersonation! session
      expect(session).not_to have_key('impersonated_provider_user')
    end
  end
end
