class CreateExampleProviderUsersWithPermissions
  def self.call
    create_provider_user({
      dfe_sign_in_uid: 'dev-provider',
      email_address: 'provider@example.com',
      first_name: 'Peter',
      last_name: 'Rovider',
    }, %w[U80 1N1])

    create_provider_user({
      dfe_sign_in_uid: 'dev-support',
      email_address: 'support@example.com',
      first_name: 'Susan',
      last_name: 'Upport',
    }, %w[U80 24J 1TZ], {
      manage_users: true,
      manage_organisations: true,
      set_up_interviews: true,
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
      training_provider: Provider.find_by(code: 'U80'),
      ratifying_provider: Provider.find_by(code: '24P'),
    ).update(
      training_provider_can_make_decisions: true,
      training_provider_can_view_safeguarding_information: true,
      training_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )

    create_provider_user({
      dfe_sign_in_uid: 'dev-U80-admin',
      email_address: 'U80-admin@example.com',
      first_name: 'U80',
      last_name: 'Admin',
    }, %w[U80], {
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
      training_provider: Provider.find_by(code: 'U80'),
      ratifying_provider: Provider.find_by(code: 'D39'),
    ).update(
      training_provider_can_make_decisions: true,
      training_provider_can_view_safeguarding_information: true,
      training_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )

    ProviderAgreement.create!(
      provider: Provider.find_by(code: 'D39'),
      provider_user: user_d39,
      agreement_type: :data_sharing_agreement,
      accept_agreement: true,
    )

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
      training_provider: Provider.find_by(code: 'U80'),
      ratifying_provider: Provider.find_by(code: 'S72'),
    ).update(
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: true,
      ratifying_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )

    ProviderAgreement.create!(
      provider: Provider.find_by(code: 'S72'),
      provider_user: user_s72,
      agreement_type: :data_sharing_agreement,
      accept_agreement: true,
    )

    # cannot_view__no_org_level_perm__without_manage_orgs__with_setup__training_provider
    create_provider_user({
      dfe_sign_in_uid: 'dev-1ZW',
      email_address: '1ZW@example.com',
      first_name: '1ZW',
      last_name: 'User',
    }, %w[1ZW], {
      view_safeguarding_information: true,
    })

    ProviderRelationshipPermissions.find_or_create_by(
      training_provider: Provider.find_by(code: '1ZW'),
      ratifying_provider: Provider.find_by(code: '24P'),
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
