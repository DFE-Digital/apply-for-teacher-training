class CreateExampleProviderUsersWithPermissions
  def self.call
    create_provider_user({
      dfe_sign_in_uid: 'dev-provider',
      email_address: 'provider@example.com',
      first_name: 'Peter',
      last_name: 'Rovider',
    }, %w[1JA 1N1])

    create_provider_user({
      dfe_sign_in_uid: 'dev-support',
      email_address: 'support@example.com',
      first_name: 'Susan',
      last_name: 'Upport',
    }, %w[1JA 1JB 24J], {
      manage_users: true,
      manage_organisations: true,
      view_safeguarding_information: true,
      make_decisions: true,
    })

    # can_view__with_safeguarding_information
    create_provider_user({
      dfe_sign_in_uid: 'dev-1N1',
      email_address: '1N1@example.com',
      first_name: '1N1',
      last_name: 'User',
    }, %w[1N1], {
      view_safeguarding_information: true,
    })

    # cannot_view__no_org_level_perm__with_manage_orgs__ratifying_provider
    create_provider_user({
      dfe_sign_in_uid: 'dev-24P',
      email_address: '24P@example.com',
      first_name: '24P',
      last_name: 'User',
    }, %w[24P], {
      manage_organisations: true,
      view_safeguarding_information: true,
    })

    ProviderRelationshipPermissions.find_or_create_by(
      training_provider: Provider.find_by_code('1JB'),
      ratifying_provider: Provider.find_by_code('24P'),
    ).update(
      training_provider_can_make_decisions: true,
      training_provider_can_view_safeguarding_information: true,
      training_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )

    # cannot_view__no_org_level_perm__with_manage_orgs__training_provider
    admin_1jb1 = create_provider_user({
      dfe_sign_in_uid: 'dev-1JB-admin-1',
      email_address: '1JB-admin-1@example.com',
      first_name: '1JB',
      last_name: 'Admin 1',
    }, %w[1JB], {
      manage_organisations: true,
      view_safeguarding_information: true,
    })

    ProviderAgreement.create!(
      provider: Provider.find_by_code('1JB'),
      provider_user: admin_1jb1,
      agreement_type: :data_sharing_agreement,
      accept_agreement: true,
    )

    create_provider_user({
      dfe_sign_in_uid: 'dev-1JB-admin-2',
      email_address: '1JB-admin-2@example.com',
      first_name: '1JB',
      last_name: 'Admin 2',
    }, %w[1JB], {
      manage_organisations: true,
      view_safeguarding_information: true,
    })

    create_provider_user({
      dfe_sign_in_uid: 'dev-1JA-admin',
      email_address: '1JA-admin@example.com',
      first_name: '1JA',
      last_name: 'Admin',
    }, %w[1JA], {
      manage_organisations: true,
      view_safeguarding_information: false,
    })

    # cannot_view__no_org_level_perm__without_manage_orgs__ratifying_provider
    user_d39 = create_provider_user({
      dfe_sign_in_uid: 'dev-D39',
      email_address: 'D39@example.com',
      first_name: 'D39',
      last_name: 'User',
    }, %w[D39], {
      view_safeguarding_information: true,
    })

    ProviderRelationshipPermissions.find_or_create_by(
      training_provider: Provider.find_by_code('1JB'),
      ratifying_provider: Provider.find_by_code('D39'),
    ).update(
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
    create_provider_user({
      dfe_sign_in_uid: 'dev-1JB-user',
      email_address: '1JB-user@example.com',
      first_name: '1JB',
      last_name: 'User',
    }, %w[1JB], {
      view_safeguarding_information: true,
    })

    # can_view__with_org_level_perm__with_user_level__ratifying_provider
    user_s72 = create_provider_user({
      dfe_sign_in_uid: 'dev-S72',
      email_address: 'S72@example.com',
      first_name: 'S72',
      last_name: 'User',
    }, %w[S72], {
      view_safeguarding_information: true,
    })

    ProviderRelationshipPermissions.find_or_create_by(
      training_provider: Provider.find_by_code('1JB'),
      ratifying_provider: Provider.find_by_code('S72'),
    ).update(
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
    create_provider_user({
      dfe_sign_in_uid: 'dev-4T7',
      email_address: '4T7@example.com',
      first_name: '4T7',
      last_name: 'User',
    }, %w[4T7], {
      view_safeguarding_information: true,
    })

    ProviderRelationshipPermissions.find_or_create_by(
      training_provider: Provider.find_by_code('4T7'),
      ratifying_provider: Provider.find_by_code('24P'),
    ).update(
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: true,
      ratifying_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )
  end

  def self.create_provider_user(attrs, provider_codes, permissions = {})
    user = ProviderUser.new(attrs)
    SaveProviderUser.new(provider_user: user).call!
    user.providers = Provider.where(code: provider_codes).all
    user.save!

    user.provider_permissions.update_all(permissions) if permissions.any?

    user
  end
end
