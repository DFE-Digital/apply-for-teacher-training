class AddDefaultPermissionsForProviderRelationships < ActiveRecord::Migration[6.0]
  def change
    # Grant permissions for all existing relationships and mark them as set up.
    ProviderRelationshipPermissions.update_all(
      ratifying_provider_can_make_decisions: true,
      training_provider_can_make_decisions: true,
      setup_at: Time.zone.now,
    )

    # Grant manage organisations permissions for all provider users who can currently manage other provider users.
    ProviderPermissions.where(manage_users: true, manage_organisations: false).update_all(manage_organisations: true)

    # Find any remaining provider organisations without a user with manage_organisations permissions.
    provider_ids_with_no_manage_org_permissions = ProviderPermissions.where(manage_organisations: false).pluck(:provider_id).uniq

    if provider_ids_with_no_manage_org_permissions.any?
      # Fetch users who accepted DSA for these unmanaged organisations.
      provider_user_ids_from_agreements = ProviderAgreement.where(provider_id: provider_ids_with_no_manage_org_permissions).pluck(:provider_user_id).uniq

      # Grant the manage_organisations permission to the user who accepted the DSA.
      ProviderPermissions.where(
        provider_user_id: provider_user_ids_from_agreements,
        provider_id: provider_ids_with_no_manage_org_permissions,
        manage_organisations: false,
      ).update_all(manage_organisations: true)
    end
  end
end
