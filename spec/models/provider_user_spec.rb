require 'rails_helper'

RSpec.describe ProviderUser do
  describe 'validations' do
    let!(:existing_provider_user) { create(:provider_user) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
  end

  describe '#downcase_email_address' do
    it 'saves email_address in lower case' do
      provider_user = create(:provider_user, email_address: 'Bob.Roberts@example.com')
      expect(provider_user.reload.email_address).to eq 'bob.roberts@example.com'
    end
  end

  describe '#full_name' do
    it 'concatenates the first and last names of the user' do
      provider_user = build(:provider_user)
      expect(provider_user.full_name).to eq "#{provider_user.first_name} #{provider_user.last_name}"
    end

    it 'is nil if the first and last names are nil' do
      provider_user = build(:provider_user, first_name: nil, last_name: nil)
      expect(provider_user.full_name).to be_nil
    end
  end

  describe 'auditing', :with_audited do
    it 'records an audit entry when creating and updating a new ProviderUser' do
      provider_user = create(:provider_user, first_name: 'Bob')
      expect(provider_user.audits.count).to eq 1
      provider_user.update(first_name: 'Alice')
      expect(provider_user.audits.count).to eq 2
    end

    it 'records an audit entry when creating adding an existing ProviderUser to a Provider' do
      provider_user = create(:provider_user, first_name: 'Bob')
      provider = create(:provider)
      expect(provider_user.audits.count).to eq 1
      provider_user.providers << provider
      expect(provider_user.associated_audits.count).to eq 1
      expect(provider_user.associated_audits.first.audited_changes['provider_id']).to eq provider.id
    end
  end

  describe 'can_manage_organisations?' do
    let(:provider_user) { create(:provider_user, :with_provider) }

    it 'is false for users without the manage organisations permission' do
      expect(provider_user.can_manage_organisations?).to be false
    end

    it 'is true for users with the manage organisations permission' do
      provider_user.provider_permissions.first.update(manage_organisations: true)

      expect(provider_user.can_manage_organisations?).to be true
    end
  end

  describe '.visible_to' do
    it 'returns provider users with access to the same providers as the passed user' do
      provider = create(:provider, :no_users)

      user_a = create(:provider_user)
      user_b = create(:provider_user, providers: [provider])
      create(:provider_permissions, provider_user: user_a, provider:, manage_users: true)

      expect(described_class.visible_to(user_a)).to include(user_b)
      expect(described_class.visible_to(user_a).count).to eq(2) # user_a can see themselves plus user_b
    end

    it 'returns only one record per user' do
      provider_a = create(:provider, :no_users)
      provider_b = create(:provider, :no_users)

      user_a = create(:provider_user)
      user_b = create(:provider_user, providers: [provider_a, provider_b])

      create(:provider_permissions, provider_user: user_a, provider: provider_a, manage_users: true)
      create(:provider_permissions, provider_user: user_a, provider: provider_b, manage_users: true)

      expect(described_class.visible_to(user_a)).to include(user_b)
      expect(described_class.visible_to(user_a).count).to eq(2) # user_a can see themselves plus user_b
    end

    it 'returns only users for providers for which the passed user has manage_users permission' do
      provider_a = create(:provider, :no_users)
      provider_b = create(:provider, :no_users)

      user_a = create(:provider_user)
      create(:provider_permissions, provider_user: user_a, provider: provider_a, manage_users: true)
      create(:provider_permissions, provider_user: user_a, provider: provider_b, manage_users: false)
      user_b = create(:provider_user, providers: [provider_a])
      user_c = create(:provider_user, providers: [provider_b])

      expect(described_class.visible_to(user_a)).to include(user_b)
      expect(described_class.visible_to(user_a)).not_to include(user_c)
    end
  end

  describe '#provieders_where_user_can_make_descisions' do
    it 'only returns providers for where a user has permission to make decisions' do
      provider_user = create(:provider_user)
      provider_without_permissions = create(:provider)
      provider_with_permissions = create(:provider)
      create(:provider_permissions, provider_user:, provider: provider_without_permissions, make_decisions: false)
      create(:provider_permissions, provider_user:, provider: provider_with_permissions, make_decisions: true)

      result = provider_user.providers_where_user_can_make_decisions
      expect(result).to contain_exactly(provider_with_permissions)
    end
  end

  describe '#last_find_candidate_filter' do
    context 'when find_a_candidate_all filter is most up to date' do
      it 'returns the most up to date find a candidate filter' do
        provider_user = create(:provider_user)
        all_filter = create(
          :provider_user_filter,
          kind: 'find_candidates_all',
          provider_user:,
        )

        create(
          :provider_user_filter,
          kind: 'find_candidates_not_seen',
          provider_user:,
          updated_at: 2.days.ago,
        )

        create(
          :provider_user_filter,
          kind: 'find_candidates_invited',
          provider_user:,
          updated_at: 2.days.ago,
        )

        expect(provider_user.last_find_candidate_filter).to eq(all_filter)
      end
    end

    context 'when find_a_candidate_not_seen filter is most up to date' do
      it 'returns the most up to date find a candidate filter' do
        provider_user = create(:provider_user)
        create(
          :provider_user_filter,
          kind: 'find_candidates_all',
          provider_user:,
          updated_at: 2.days.ago,
        )

        not_seen_filter = create(
          :provider_user_filter,
          kind: 'find_candidates_not_seen',
          provider_user:,
        )

        create(
          :provider_user_filter,
          kind: 'find_candidates_invited',
          provider_user:,
          updated_at: 2.days.ago,
        )

        expect(provider_user.last_find_candidate_filter).to eq(not_seen_filter)
      end
    end

    context 'when find_a_candidate_invited filter is most up to date' do
      it 'returns the most up to date find a candidate filter' do
        provider_user = create(:provider_user)
        create(
          :provider_user_filter,
          kind: 'find_candidates_all',
          provider_user:,
          updated_at: 2.days.ago,
        )

        create(
          :provider_user_filter,
          kind: 'find_candidates_not_seen',
          provider_user:,
          updated_at: 2.days.ago,
        )

        invited_filter = create(
          :provider_user_filter,
          kind: 'find_candidates_invited',
          provider_user:,
        )

        expect(provider_user.last_find_candidate_filter).to eq(invited_filter)
      end
    end
  end

  describe '.find_or_onboard' do
    it 'finds the provider user' do
      provider_user = create(:provider_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID')

      call = described_class.find_or_onboard({ 'uid' => 'DFE_SIGN_IN_UID' })

      expect(call).to eq(provider_user)
    end

    context 'when provider_user with dfe_sign_in_uid does not exist' do
      it 'onboards the provider_user' do
        provider_user = create(
          :provider_user,
          dfe_sign_in_uid: nil,
          email_address: 'test@email.com',
        )

        call = described_class.find_or_onboard(
          { 'info' => { 'email' => 'test@email.com' } },
        )

        expect(call).to eq(provider_user)
      end
    end
  end

  describe '.load_from_current_session' do
    context 'when session does not exists' do
      it 'return nil' do
        expect(described_class.load_from_current_session).to be_nil
      end
    end

    context 'when provider session exists' do
      it 'return the provider user from the session' do
        provider_session = create(:dsi_session)

        allow(Current).to receive(:provider_session).and_return(provider_session)
        expect(described_class.load_from_current_session).to eq(provider_session.provider_user)
      end
    end

    context 'when support session exists and it is impersonating' do
      it 'return the provider user from the session' do
        support_session = create(:dsi_session, :support_user_impersonating_provider)

        allow(Current).to receive(:support_session).and_return(support_session)
        expect(described_class.load_from_current_session).to eq(support_session.impersonated_provider_user)
      end
    end

    context 'when support session exists but does not impersonate' do
      it 'return the provider user from the session' do
        support_session = create(:dsi_session, :support_user)

        allow(Current).to receive(:support_session).and_return(support_session)
        expect(described_class.load_from_current_session).to be_nil
      end
    end
  end
end
