require 'rails_helper'

RSpec.describe SupportInterface::ProviderAccessControlsExport, with_audited: true do
  describe '#data_for_export' do
    it 'returns access control data for providers' do
      Timecop.freeze(2020, 5, 1, 12, 0, 0) do
        training_provider = create(:provider)
        ratifying_provider = create(:provider)

        provider_user1 = create(
          :provider_user,
          :with_view_safeguarding_information,
          :with_make_decisions,
          :with_manage_users,
          :with_manage_organisations,
          providers: [training_provider],
          last_signed_in_at: 15.days.ago,
        )

        provider_user2 = create(
          :provider_user,
          :with_view_safeguarding_information,
          :with_make_decisions,
          :with_manage_users,
          providers: [ratifying_provider],
          last_signed_in_at: 10.days.ago,
        )

        provider_user3 = create(
          :provider_user,
          :with_view_diversity_information,
          :with_make_decisions,
          :with_manage_users,
          providers: [ratifying_provider],
          last_signed_in_at: 5.days.ago,
        )

        user_signs_dsa_for_provider(provider_user1, training_provider, 2.months.ago)
        user_signs_dsa_for_provider(provider_user2, ratifying_provider, 3.months.ago)
        user_signs_dsa_for_provider(provider_user3, ratifying_provider, 1.month.ago)

        setup_org_permissions(training_provider, ratifying_provider)

        provider_user_sets_their_view_diversity_information_to_true(provider_user1, 1.day.ago)
        provider_user_sets_org_can_view_diversity_information_to_true(provider_user1, training_provider, 2.days.ago)

        provider_user_sets_their_view_diversity_information_to_true(provider_user2, 10.days.ago)
        provider_user_sets_their_view_safeguarding_information_to_true(provider_user3, 2.days.ago)

        expect(described_class.new.data_for_export).to match_array([
          {
            name: training_provider.name,
            dsa_signer: provider_user1.email_address,
            last_user_permissions_change_at: 1.day.ago,
            total_user_permissions_changes: 1,
            user_permissions_changed_by: [provider_user1.email_address],
            last_org_permissions_change_at: 2.days.ago,
            total_org_relationships_as_trainer: 1,
            total_org_relationships: 1,
            total_org_permissions_changes: 1,
            org_permissions_changed_by: [provider_user1.email_address],
            total_users: 1,
            total_manage_users_users: 1,
            total_manage_orgs_users: 1,
          },
          {
            name: ratifying_provider.name,
            dsa_signer: provider_user3.email_address,
            last_user_permissions_change_at: 2.days.ago,
            total_user_permissions_changes: 2,
            user_permissions_changed_by: [provider_user2.email_address, provider_user3.email_address],
            last_org_permissions_change_at: nil,
            total_org_relationships_as_trainer: 0,
            total_org_relationships: 1,
            total_org_permissions_changes: 0,
            org_permissions_changed_by: [],
            total_users: 2,
            total_manage_users_users: 2,
            total_manage_orgs_users: 0,
          },
        ])
      end
    end
  end

  def user_signs_dsa_for_provider(provider_user, provider, time_signed)
    create(:provider_agreement, provider_user: provider_user, provider: provider, accepted_at: time_signed)
  end

  def setup_org_permissions(training_provider, ratifying_provider)
    create(
      :provider_relationship_permissions,
      training_provider: training_provider,
      ratifying_provider: ratifying_provider,
    )
  end

  def provider_user_sets_their_view_diversity_information_to_true(provider_user, time)
    Audited.audit_class.as_user(provider_user) do
      Timecop.freeze(time) do
        provider_user.provider_permissions.last.update!(view_diversity_information: true)
      end
    end
  end

  def provider_user_sets_their_view_safeguarding_information_to_true(provider_user, time)
    Audited.audit_class.as_user(provider_user) do
      Timecop.freeze(time) do
        provider_user.provider_permissions.last.update!(view_safeguarding_information: true)
      end
    end
  end

  def provider_user_sets_org_can_view_diversity_information_to_true(provider_user, provider, time)
    Audited.audit_class.as_user(provider_user) do
      Timecop.freeze(time) do
        provider.training_provider_permissions.last.update!(ratifying_provider_can_view_diversity_information: true)
      end
    end
  end
end
