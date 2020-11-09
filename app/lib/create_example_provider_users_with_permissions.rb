class CreateExampleProviderUsersWithPermissions
  def self.call
    # can_view__with_safeguarding_information
    user_1n1 = ProviderUser.create!(
      dfe_sign_in_uid: 'dev-1N1',
      email_address: '1N1@example.com',
      first_name: '1N1',
      last_name: 'User',
    ) do |u|
      u.providers = Provider.where(code: '1N1')
    end

    user_1n1.provider_permissions.update_all(
      view_safeguarding_information: true,
    )

    # cannot_view__no_org_level_perm__with_manage_orgs__ratifying_provider
    user_24p = ProviderUser.create!(
      dfe_sign_in_uid: 'dev-24P',
      email_address: '24P@example.com',
      first_name: '24P',
      last_name: 'User',
    ) do |u|
      u.providers = Provider.where(code: '24P')
    end

    user_24p.provider_permissions.update_all(
      manage_organisations: true,
      view_safeguarding_information: true,
    )

    ProviderRelationshipPermissions.find_or_create_by(
      training_provider: Provider.find_by_code('1JB'),
      ratifying_provider: Provider.find_by_code('24P'),
    ).update_columns(
      training_provider_can_make_decisions: true,
      training_provider_can_view_safeguarding_information: true,
      training_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )

    # cannot_view__no_org_level_perm__with_manage_orgs__training_provider
    admin_1jb1 = ProviderUser.create!(
      dfe_sign_in_uid: 'dev-1JB-admin-1',
      email_address: '1JB-admin-1@example.com',
      first_name: '1JB',
      last_name: 'Admin 1',
    ) do |u|
      u.providers = Provider.where(code: '1JB')
    end

    admin_1jb1.provider_permissions.update_all(
      manage_organisations: true,
      view_safeguarding_information: true,
    )

    ProviderAgreement.create!(
      provider: Provider.find_by_code('1JB'),
      provider_user: admin_1jb1,
      agreement_type: :data_sharing_agreement,
      accept_agreement: true,
    )

    admin_1jb2 = ProviderUser.create!(
      dfe_sign_in_uid: 'dev-1JB-admin-2',
      email_address: '1JB-admin-2@example.com',
      first_name: '1JB',
      last_name: 'Admin 2',
    ) do |u|
      u.providers = Provider.where(code: '1JB')
    end

    admin_1jb2.provider_permissions.update_all(
      manage_organisations: true,
      view_safeguarding_information: true,
    )

    admin_1ja = ProviderUser.create!(
      dfe_sign_in_uid: 'dev-1JA-admin',
      email_address: '1JA-admin@example.com',
      first_name: '1JA',
      last_name: 'Admin',
    ) do |u|
      u.providers = Provider.where(code: '1JA')
    end

    admin_1ja.provider_permissions.update_all(
      manage_organisations: true,
      view_safeguarding_information: false,
    )

    # cannot_view__no_org_level_perm__without_manage_orgs__ratifying_provider
    user_d39 = ProviderUser.create!(
      dfe_sign_in_uid: 'dev-D39',
      email_address: 'D39@example.com',
      first_name: 'D39',
      last_name: 'User',
    ) do |u|
      u.providers = Provider.where(code: 'D39')
    end

    user_d39.provider_permissions.update_all(
      view_safeguarding_information: true,
    )

    ProviderRelationshipPermissions.find_or_create_by(
      training_provider: Provider.find_by_code('1JB'),
      ratifying_provider: Provider.find_by_code('D39'),
    ).update_columns(
      training_provider_can_make_decisions: true,
      training_provider_can_view_safeguarding_information: true,
      training_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )

    ProviderAgreement.create!(
      provider: Provider.find_by_code('D39'),
      provider_user: user_d39,
      agreement_type: :data_sharing_agreement,
      accept_agreement: true,
    )

    # cannot_view__no_org_level_perm__without_manage_orgs__without_setup__training_provider
    user_1jb = ProviderUser.create!(
      dfe_sign_in_uid: 'dev-1JB-user',
      email_address: '1JB-user@example.com',
      first_name: '1JB',
      last_name: 'User',
    ) do |u|
      u.providers = Provider.where(code: '1JB')
    end

    user_1jb.provider_permissions.update_all(
      view_safeguarding_information: true,
    )

    # can_view__with_org_level_perm__with_user_level__ratifying_provider
    user_s72 = ProviderUser.create!(
      dfe_sign_in_uid: 'dev-S72',
      email_address: 'S72@example.com',
      first_name: 'S72',
      last_name: 'User',
    ) do |u|
      u.providers = Provider.where(code: 'S72')
    end

    user_s72.provider_permissions.update_all(
      view_safeguarding_information: true,
    )

    ProviderRelationshipPermissions.find_or_create_by(
      training_provider: Provider.find_by_code('1JB'),
      ratifying_provider: Provider.find_by_code('S72'),
    ).update_columns(
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: true,
      ratifying_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )

    ProviderAgreement.create!(
      provider: Provider.find_by_code('S72'),
      provider_user: user_s72,
      agreement_type: :data_sharing_agreement,
      accept_agreement: true,
    )

    # cannot_view__no_org_level_perm__without_manage_orgs__with_setup__training_provider
    user_4t7 = ProviderUser.create!(
      dfe_sign_in_uid: 'dev-4T7',
      email_address: '4T7@example.com',
      first_name: '4T7',
      last_name: 'User',
    ) do |u|
      u.providers = Provider.where(code: '4T7')
    end

    user_4t7.provider_permissions.update_all(
      view_safeguarding_information: true,
    )

    ProviderRelationshipPermissions.find_or_create_by(
      training_provider: Provider.find_by_code('4T7'),
      ratifying_provider: Provider.find_by_code('24P'),
    ).update_columns(
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: true,
      ratifying_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )
  end
end
