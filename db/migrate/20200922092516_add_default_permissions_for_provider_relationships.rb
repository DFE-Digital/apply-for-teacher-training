class AddDefaultPermissionsForProviderRelationships < ActiveRecord::Migration[6.0]
  def change
    Rails.logger.info 'Granting make_decisions permissions for all existing relationships and marking them as set up.'
    ProviderRelationshipPermissions.update_all(
      ratifying_provider_can_make_decisions: true,
      training_provider_can_make_decisions: true,
      setup_at: Time.zone.now,
    )

    Rails.logger.info 'Granting manage_organisations permissions for all provider users who can currently manage other provider users.'
    permissions_to_update = ProviderPermissions.where(manage_users: true, manage_organisations: false)
    permissions_to_update.update_all(manage_organisations: true)

    # Find any remaining provider organisations without a user with manage_organisations permissions.
    provider_ids_with_no_manage_org_permissions = ProviderPermissions
      .where.not(provider_id: permissions_to_update.pluck(:provider_id).uniq)
      .where(manage_organisations: false)
      .pluck(:provider_id).uniq.compact

    if provider_ids_with_no_manage_org_permissions.any?
      # Fetch users who accepted DSA for these unmanaged organisations.
      provider_user_ids_from_agreements = ProviderAgreement
        .joins('INNER JOIN provider_users ON provider_agreements.provider_user_id = provider_users.id')
        .where(provider_id: provider_ids_with_no_manage_org_permissions)
        .pluck(:provider_user_id).uniq.compact

      Rails.logger.info 'Granting the manage_organisations permissions to the users who accepted the DSA for orgs with no apparent admin user.'
      ProviderPermissions.where(
        provider_user_id: provider_user_ids_from_agreements,
        provider_id: provider_ids_with_no_manage_org_permissions,
        manage_organisations: false,
      ).update_all(manage_organisations: true)
    end

    # Find any orgs with no signed DSA.
    providers_with_no_signed_dsa = Provider.where.not(id: ProviderAgreement.all.select(:provider_id))

    # Assign the manage orgs permission to the first user for each of these.
    providers_with_no_signed_dsa.each do |provider|
      provider_user = provider.provider_users.first # !Can be nil!
      permissions_for_providers_with_unsigned_dsa = ProviderPermissions.find_by(provider:, provider_user:)

      if provider_user.present? && permissions_for_providers_with_unsigned_dsa.present?
        Rails.logger.info "Assigning manage_organisations permissions to ProviderUser(id: #{provider_user.id}) for #{provider.name}"
        permissions_for_providers_with_unsigned_dsa.update!(manage_organisations: true)
      end
    end
  end
end
