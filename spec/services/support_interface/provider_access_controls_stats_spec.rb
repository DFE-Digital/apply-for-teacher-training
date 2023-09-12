require 'rails_helper'

RSpec.describe SupportInterface::ProviderAccessControlsStats, :with_audited do
  let(:support_user) { create(:support_user) }
  let(:provider) { create(:provider, :no_users) }

  describe '#dsa_signer_email' do
    let(:provider) { create(:provider, :no_users, :unsigned) }

    it 'returns the email of the user who most recently accepted the dsa' do
      user1 = create(:provider_user, providers: [provider])
      user2 = create(:provider_user, providers: [provider])
      create(:provider_agreement, provider_user: user1, provider:, accepted_at: 1.day.ago)
      create(:provider_agreement, provider_user: user2, provider:, accepted_at: 3.days.ago)

      access_controls = described_class.new(provider)

      expect(access_controls.dsa_signer_email).to eq user1.email_address
    end

    it 'returns nil if the dsa has not been signed' do
      create(:provider_user, providers: [provider])

      access_controls = described_class.new(provider)

      expect(access_controls.dsa_signer_email).to be_nil
    end
  end

  describe '#user_permissions_last_changed_at' do
    it 'returns the date that user permissions were last edited at' do
      travel_temporarily_to(2020, 9, 25, 12, 0, 0) do
        provider_user = create(:provider_user, providers: [provider])

        first_edit_time = 3.days.ago
        second_edit_time = 1.day.ago

        Audited.audit_class.as_user(provider_user) do
          travel_temporarily_to(first_edit_time) do
            provider_user.provider_permissions.last.update!(view_diversity_information: true)
          end
          travel_temporarily_to(second_edit_time) do
            provider_user.provider_permissions.last.update!(view_safeguarding_information: true)
          end
        end

        access_controls = described_class.new(provider)

        expect(access_controls.user_permissions_last_changed_at).to eq second_edit_time
      end
    end

    it 'returns nil if user permissions have never been updated' do
      create(:provider_user, providers: [provider])

      access_controls = described_class.new(provider)

      expect(access_controls.user_permissions_last_changed_at).to be_nil
    end
  end

  describe '#total_user_permissions_changes' do
    it 'returns the number of times the user permissions have been updated for the provider' do
      provider_user = create(:provider_user, providers: [provider])

      Audited.audit_class.as_user(provider_user) do
        provider_user.provider_permissions.last.update!(view_diversity_information: true)
        provider_user.provider_permissions.last.update!(view_safeguarding_information: true)
      end

      access_controls = described_class.new(provider)

      expect(access_controls.total_user_permissions_changes).to eq 2
    end

    it 'returns 0 if there have been no changes' do
      create(:provider_user, providers: [provider])

      access_controls = described_class.new(provider)

      expect(access_controls.total_user_permissions_changes).to eq 0
    end

    it 'ignores changes that were made by support users' do
      provider_user = create(:provider_user, providers: [provider])

      Audited.audit_class.as_user(support_user) do
        provider_user.provider_permissions.last.update!(view_diversity_information: true)
      end

      access_controls = described_class.new(provider)

      expect(access_controls.total_user_permissions_changes).to eq 0
    end
  end

  describe '#total_user_permissions_changes_made_by_support' do
    it 'returns the number of times the user permissions have been updated for the provider by support users' do
      provider_user = create(:provider_user, providers: [provider])

      Audited.audit_class.as_user(support_user) do
        provider_user.provider_permissions.last.update!(view_diversity_information: true)
        provider_user.provider_permissions.last.update!(view_safeguarding_information: true)
      end

      access_controls = described_class.new(provider)

      expect(access_controls.total_user_permissions_changes_made_by_support).to eq 2
    end

    it 'ignores changes that were made by other users' do
      provider_user = create(:provider_user, providers: [provider])

      Audited.audit_class.as_user('Not a support user') do
        provider_user.provider_permissions.last.update!(view_diversity_information: true)
      end

      access_controls = described_class.new(provider)

      expect(access_controls.total_user_permissions_changes_made_by_support).to eq 0
    end
  end

  describe '#user_permissions_changed_by' do
    it 'returns a list of emails for users that have updated user permissions for the provider' do
      provider_user1 = create(:provider_user, providers: [provider])
      provider_user2 = create(:provider_user, providers: [provider])

      Audited.audit_class.as_user(provider_user1) do
        provider_user1.provider_permissions.last.update!(view_diversity_information: true)
      end
      Audited.audit_class.as_user(provider_user2) do
        provider_user1.provider_permissions.last.update!(view_safeguarding_information: true)
      end

      access_controls = described_class.new(provider)

      expect(access_controls.user_permissions_changed_by).to contain_exactly(provider_user1.email_address, provider_user2.email_address)
    end

    it 'returns an empty array if there have been no changes' do
      create(:provider_user, providers: [provider])

      access_controls = described_class.new(provider)

      expect(access_controls.user_permissions_changed_by).to eq []
    end

    it 'ignores changes that were not made by provider users' do
      provider_user1 = create(:provider_user, providers: [provider])

      Audited.audit_class.as_user('Not a provider user') do
        provider_user1.provider_permissions.last.update!(view_diversity_information: true)
      end

      access_controls = described_class.new(provider)

      expect(access_controls.user_permissions_changed_by).to eq []
    end

    it 'ignores changes if provider user has been deleted' do
      provider_user = create(:provider_user, providers: [provider])

      Audited.audit_class.as_user(provider_user) do
        provider_user.provider_permissions.last.update!(view_diversity_information: true)
      end

      provider_user.delete
      access_controls = described_class.new(provider)

      expect(access_controls.user_permissions_changed_by).to be_empty
    end
  end

  describe '#total_manage_users_users' do
    it 'returns the number of provider users in the provider that have the manage users permission' do
      create(:provider_user, :with_manage_users, providers: [provider])
      create(:provider_user, :with_manage_users, providers: [provider])
      create(:provider_user, providers: [provider])

      access_controls = described_class.new(provider)

      expect(access_controls.total_manage_users_users).to eq 2
    end
  end

  describe '#total_manage_orgs_users' do
    it 'returns the number of provider users in the provider that have the manage organisations permission' do
      create(:provider_user, :with_manage_users, providers: [provider])
      create(:provider_user, :with_manage_organisations, providers: [provider])
      create(:provider_user, :with_manage_organisations, providers: [provider])

      access_controls = described_class.new(provider)

      expect(access_controls.total_manage_orgs_users).to eq 2
    end
  end

  context 'org_permissions' do
    describe 'date_of_last' do
      it 'returns nil if org permissions have never been updated' do
        create(:provider_user, providers: [provider])

        access_controls = described_class.new(provider)

        expect(access_controls.date_of_last_org_permissions_change_made_by_this_provider_affecting_this_provider).to be_nil
        expect(access_controls.date_of_last_org_permissions_change_made_by_this_provider_affecting_another_provider).to be_nil
        expect(access_controls.date_of_last_org_permissions_change_affecting_this_provider).to be_nil
      end
    end

    describe 'total' do
      it 'returns 0 if there have been no changes' do
        create(:provider_user, providers: [provider])

        access_controls = described_class.new(provider)

        expect(access_controls.total_org_permissions_changes_made_by_this_provider_affecting_this_provider).to eq 0
        expect(access_controls.total_org_permissions_changes_made_by_this_provider_affecting_another_provider).to eq 0
        expect(access_controls.total_org_permissions_changes_affecting_this_provider).to eq 0
        expect(access_controls.total_org_permissions_changes_made_by_support).to eq 0
      end

      it 'includes changes made by support and provider users where appropriate' do
        training_provider = create(:provider, :no_users)
        ratifying_provider = create(:provider, :no_users)

        create(:provider_relationship_permissions, training_provider:, ratifying_provider:)

        provider_user = create(:provider_user, providers: [training_provider])

        Audited.audit_class.as_user(provider_user) do
          training_provider.training_provider_permissions.last.update!(ratifying_provider_can_view_safeguarding_information: true)
          training_provider.training_provider_permissions.last.update!(training_provider_can_view_safeguarding_information: false)
        end

        Audited.audit_class.as_user(support_user) do
          training_provider.training_provider_permissions.last.update!(ratifying_provider_can_make_decisions: true)
          training_provider.training_provider_permissions.last.update!(training_provider_can_make_decisions: false)
        end

        access_controls = described_class.new(training_provider)

        expect(access_controls.total_org_permissions_changes_made_by_this_provider_affecting_this_provider).to eq 1
        expect(access_controls.total_org_permissions_changes_made_by_this_provider_affecting_another_provider).to eq 1
        expect(access_controls.total_org_permissions_changes_affecting_this_provider).to eq 2
        expect(access_controls.total_org_permissions_changes_made_by_support).to eq 1
      end
    end

    describe '#org_permissions_changed_by' do
      it 'ignores changes that were not made by provider users' do
        training_provider = create(:provider, :no_users)
        ratifying_provider = create(:provider, :no_users)

        create(:provider_relationship_permissions, training_provider:, ratifying_provider:)

        create(:provider_user, providers: [training_provider])

        Audited.audit_class.as_user('Not a provider user') do
          training_provider.training_provider_permissions.last.update!(ratifying_provider_can_view_safeguarding_information: true)
        end

        access_controls = described_class.new(training_provider)

        expect(access_controls.org_permissions_changes_made_by_this_provider_affecting_this_provider_made_by).to eq []
        expect(access_controls.org_permissions_changes_made_by_this_provider_affecting_another_provider_made_by).to eq []
        expect(access_controls.org_permissions_changes_affecting_this_provider_made_by).to eq []
      end

      it 'ignores deleted provider users' do
        training_provider = create(:provider, :no_users)
        ratifying_provider = create(:provider, :no_users)

        create(:provider_relationship_permissions, training_provider:, ratifying_provider:)

        provider_user = create(:provider_user, providers: [training_provider])

        Audited.audit_class.as_user(provider_user) do
          training_provider.training_provider_permissions.last.update!(ratifying_provider_can_view_safeguarding_information: true)
        end
        provider_user.delete
        access_controls = described_class.new(training_provider)

        expect(access_controls.org_permissions_changes_made_by_this_provider_affecting_this_provider_made_by).to eq []
        expect(access_controls.org_permissions_changes_made_by_this_provider_affecting_another_provider_made_by).to eq []
        expect(access_controls.org_permissions_changes_affecting_this_provider_made_by).to eq []
      end
    end
  end

  describe '#total_org_relationships_as_trainer' do
    it 'returns the number of org relationships which the provider is the trainer' do
      training_provider = create(:provider)
      ratifying_provider1 = create(:provider)
      ratifying_provider2 = create(:provider)

      create(:provider_relationship_permissions, training_provider:, ratifying_provider: ratifying_provider1)
      create(:provider_relationship_permissions, training_provider:, ratifying_provider: ratifying_provider2)

      access_controls = described_class.new(training_provider)

      expect(access_controls.total_org_relationships_as_trainer).to eq 2
    end
  end

  describe '#total_org_relationships' do
    it 'returns the number of org relationships which the provider is part of' do
      provider = create(:provider)
      ratifying_provider = create(:provider)
      training_provider = create(:provider)

      create(:provider_relationship_permissions, training_provider: provider, ratifying_provider:)
      create(:provider_relationship_permissions, training_provider:, ratifying_provider: provider)

      access_controls = described_class.new(provider)

      expect(access_controls.total_org_relationships).to eq 2
    end

    it 'does not count the relationship twice if the provider is the trainer and ratifier' do
      provider = create(:provider)

      create(:provider_relationship_permissions, training_provider: provider, ratifying_provider: provider)

      access_controls = described_class.new(provider)

      expect(access_controls.total_org_relationships).to eq 1
    end
  end
end
