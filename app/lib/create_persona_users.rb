class CreatePersonaUsers
  def self.call
    create_personas_for_self_ratified_provider
    create_personas_with_multiple_providers
    create_personas_with_courseless_relationship
  end

  def self.create_personas_for_self_ratified_provider
    self_ratified_provider = Provider.find_by(code: '1N1')

    create_provider_user(
      self_ratified_provider,
      {
        dfe_sign_in_uid: persona_uid(:self_ratified_user),
        email_address: 'self.ratified.user@example.com',
        first_name: 'Anne',
        last_name: 'Apples',
      },
    )

    self_ratified_admin = create_provider_user(
      self_ratified_provider,
      {
        dfe_sign_in_uid: persona_uid(:self_ratified_admin),
        email_address: 'self.ratified.admin@example.com',
        first_name: 'Bradley',
        last_name: 'Banana',
      },
      {
        manage_users: true,
        manage_organisations: true,
      },
    )

    ProviderAgreement.create!(
      provider: self_ratified_provider,
      provider_user: self_ratified_admin,
      agreement_type: :data_sharing_agreement,
      accept_agreement: true,
    )
  end

  def self.create_personas_with_multiple_providers
    providers = Provider.where(code: %w[U80 24J]).all

    create_provider_user(
      providers,
      {
        dfe_sign_in_uid: persona_uid(:multiple_organisations_user),
        email_address: 'multiple.providers.user@example.com',
        first_name: 'Cameron',
        last_name: 'Carrot',
      },
    )

    multiple_providers_admin = create_provider_user(
      providers,
      {
        dfe_sign_in_uid: persona_uid(:multiple_organisations_admin),
        email_address: 'multiple.providers.admin@example.com',
        first_name: 'Deborah',
        last_name: 'Durian',
      },
      {
        manage_users: true,
        manage_organisations: true,
      },
    )

    providers.each do |provider|
      ProviderAgreement.create!(
        provider:,
        provider_user: multiple_providers_admin,
        agreement_type: :data_sharing_agreement,
        accept_agreement: true,
      )
    end
  end

  def self.create_personas_with_courseless_relationship
    courseless_provider = Provider.find_by(code: 'W53')

    courseless_user = create_provider_user(
      courseless_provider,
      {
        dfe_sign_in_uid: persona_uid(:no_courses_organisation_user),
        email_address: 'no.courses.user@example.com',
        first_name: 'Elvis',
        last_name: 'Eggplant',
      },
    )

    create_provider_user(
      courseless_provider,
      {
        dfe_sign_in_uid: persona_uid(:no_courses_organisation_admin),
        email_address: 'no.courses.admin@example.com',
        first_name: 'Fiona',
        last_name: 'Fig',
      },
      {
        manage_users: true,
        manage_organisations: true,
      },
    )

    ProviderAgreement.create!(
      provider: courseless_provider,
      provider_user: courseless_user,
      agreement_type: :data_sharing_agreement,
      accept_agreement: true,
    )
  end

  def self.create_provider_user(providers, attrs, permissions = {})
    user = ProviderUser.new(attrs)
    SaveProviderUser.new(provider_user: user).call!
    user.providers = Array.wrap(providers)
    user.save!

    user.provider_permissions.update_all(permissions) if permissions.any?

    user
  end

  def self.persona_uid(persona_type)
    I18n.t("personas.users.#{persona_type}.uid")
  end
end
