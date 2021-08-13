require 'rails_helper'

RSpec.describe ProviderUser, type: :model do
  describe '#downcase_email_address' do
    it 'saves email_address in lower case' do
      provider_user = create :provider_user, email_address: 'Bob.Roberts@example.com'
      expect(provider_user.reload.email_address).to eq 'bob.roberts@example.com'
    end
  end

  describe '.onboard!' do
    it 'sets the DfE Sign-in ID on an existing user' do
      provider_user = create :provider_user, dfe_sign_in_uid: nil
      dsi_user = DfESignInUser.new(
        email_address: provider_user.email_address,
        dfe_sign_in_uid: 'ABC123',
        first_name: nil,
        last_name: nil,
      )
      described_class.onboard!(dsi_user)
      expect(provider_user.reload.dfe_sign_in_uid).to eq 'ABC123'
    end

    it 'sets the DfE Sign-in ID on an existing user with a mixed case DfE Sign-in email' do
      provider_user = create :provider_user, dfe_sign_in_uid: nil, email_address: 'bob@example.com'
      dsi_user = DfESignInUser.new(
        email_address: 'BoB@example.com',
        dfe_sign_in_uid: 'ABC123',
        first_name: nil,
        last_name: nil,
      )
      described_class.onboard!(dsi_user)
      expect(provider_user.reload.dfe_sign_in_uid).to eq 'ABC123'
    end
  end

  describe '#full_name' do
    it 'concatenates the first and last names of the user' do
      provider_user = build :provider_user
      expect(provider_user.full_name).to eq "#{provider_user.first_name} #{provider_user.last_name}"
    end

    it 'is nil if the first and last names are nil' do
      provider_user = build(:provider_user, first_name: nil, last_name: nil)
      expect(provider_user.full_name).to be_nil
    end
  end

  describe 'auditing', with_audited: true do
    it 'records an audit entry when creating and updating a new ProviderUser' do
      provider_user = create :provider_user, first_name: 'Bob'
      expect(provider_user.audits.count).to eq 1
      provider_user.update(first_name: 'Alice')
      expect(provider_user.audits.count).to eq 2
    end

    it 'records an audit entry when creating adding an existing ProviderUser to a Provider' do
      provider_user = create :provider_user, first_name: 'Bob'
      provider = create :provider
      expect(provider_user.audits.count).to eq 1
      provider_user.providers << provider
      expect(provider_user.associated_audits.count).to eq 1
      expect(provider_user.associated_audits.first.audited_changes['provider_id']).to eq provider.id
    end
  end

  describe 'can_manage_organisations?' do
    let(:provider_user) { create :provider_user, :with_provider }

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
      provider = create(:provider)

      user_a = create(:provider_user)
      user_b = create(:provider_user, providers: [provider])
      create(:provider_permissions, provider_user: user_a, provider: provider, manage_users: true)

      expect(described_class.visible_to(user_a)).to include(user_b)
      expect(described_class.visible_to(user_a).count).to eq(2) # user_a can see themselves plus user_b
    end

    it 'returns only one record per user' do
      provider_a = create(:provider)
      provider_b = create(:provider)

      user_a = create(:provider_user)
      user_b = create(:provider_user, providers: [provider_a, provider_b])

      create(:provider_permissions, provider_user: user_a, provider: provider_a, manage_users: true)
      create(:provider_permissions, provider_user: user_a, provider: provider_b, manage_users: true)

      expect(described_class.visible_to(user_a)).to include(user_b)
      expect(described_class.visible_to(user_a).count).to eq(2) # user_a can see themselves plus user_b
    end

    it 'returns only users for providers for which the passed user has manage_users permission' do
      provider_a = create(:provider)
      provider_b = create(:provider)

      user_a = create(:provider_user)
      create(:provider_permissions, provider_user: user_a, provider: provider_a, manage_users: true)
      create(:provider_permissions, provider_user: user_a, provider: provider_b, manage_users: false)
      user_b = create(:provider_user, providers: [provider_a])
      user_c = create(:provider_user, providers: [provider_b])

      expect(described_class.visible_to(user_a)).to include(user_b)
      expect(described_class.visible_to(user_a)).not_to include(user_c)
    end
  end

  describe '#load_from_session' do
    let(:dsi_user) { build(:dfe_sign_in_user) }

    it 'returns nil if there is no DfESignInUser session' do
      provider_user = described_class.load_from_session({})
      expect(provider_user).to be_nil
    end

    it 'returns nil if there is no associated ProviderUser' do
      allow(DfESignInUser).to receive(:load_from_session).and_return(dsi_user)
      provider_user = described_class.load_from_session({})
      expect(provider_user).to be_nil
    end

    it 'returns the associated ProviderUser' do
      allow(DfESignInUser).to receive(:load_from_session).and_return(dsi_user)
      provider_user = create(
        :provider_user,
        dfe_sign_in_uid: dsi_user.dfe_sign_in_uid,
        email_address: dsi_user.email_address,
        first_name: dsi_user.first_name,
        last_name: dsi_user.last_name,
      )
      expect(described_class.load_from_session({})).to eq(provider_user)
    end

    it 'returns impersonated_provider_user from SupportUser, if available' do
      allow(DfESignInUser).to receive(:load_from_session).and_return(dsi_user)

      support_user = create(:support_user)
      provider_user = create(:provider_user)
      support_user.impersonated_provider_user = provider_user
      allow(SupportUser).to receive(:load_from_session).and_return(support_user)

      loaded_user = described_class.load_from_session({})

      expect(loaded_user).to eq(provider_user)
      expect(loaded_user.impersonator).to eq(support_user)
    end
  end

  describe '#primary_provider_type' do
    it 'returns university if the user belongs to a university provider organisation' do
      provider_user = build_stubbed(:provider_user, providers: [
        build_stubbed(:provider, provider_type: 'university'),
        build_stubbed(:provider, provider_type: 'scitt'),
        build_stubbed(:provider, provider_type: 'school_direct'),
      ])

      expect(provider_user.primary_provider_type).to eq('university')
    end

    it 'returns scitt if the user belongs to a scitt provider organisation but not a university' do
      provider_user = build_stubbed(:provider_user, providers: [
        build_stubbed(:provider, provider_type: 'scitt'),
        build_stubbed(:provider, provider_type: 'school_direct'),
      ])

      expect(provider_user.primary_provider_type).to eq('scitt')
    end

    it 'returns school_direct if the user only belongs to schools direct providers' do
      provider_user = build_stubbed(:provider_user, providers: [
        build_stubbed(:provider, provider_type: 'school_direct'),
        build_stubbed(:provider, provider_type: 'school_direct'),
      ])

      expect(provider_user.primary_provider_type).to eq('school_direct')
    end
  end
end
