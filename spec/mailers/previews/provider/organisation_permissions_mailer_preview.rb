class Provider::OrganisationPermissionsMailerPreview < ActionMailer::Preview
  def organisation_permissions_set_up
    training_provider = FactoryBot.create(:provider)
    ratifying_provider = FactoryBot.create(:provider)
    provider_user = FactoryBot.create(:provider_user, providers: [ratifying_provider])
    provider_user.provider_permissions.update_all(manage_organisations: true)
    permissions = FactoryBot.create(
      :provider_relationship_permissions,
      training_provider:,
      ratifying_provider:,
      ratifying_provider_can_make_decisions: true,
      training_provider_can_view_safeguarding_information: false,
      ratifying_provider_can_view_safeguarding_information: true,
      ratifying_provider_can_view_diversity_information: true,
    )
    ProviderMailer.organisation_permissions_set_up(provider_user, ratifying_provider, permissions)
  end

  def organisation_permissions_updated
    training_provider = FactoryBot.create(:provider)
    ratifying_provider = FactoryBot.create(:provider)
    provider_user = FactoryBot.create(:provider_user, providers: [ratifying_provider])
    provider_user.provider_permissions.update_all(manage_organisations: true)
    permissions = FactoryBot.create(
      :provider_relationship_permissions,
      training_provider:,
      ratifying_provider:,
      ratifying_provider_can_make_decisions: true,
      training_provider_can_make_decisions: false,
      ratifying_provider_can_view_safeguarding_information: true,
    )
    ProviderMailer.organisation_permissions_updated(provider_user, ratifying_provider, permissions)
  end

  def permissions_granted
    provider = FactoryBot.create(:provider)
    permissions_granted_by_user = FactoryBot.create(:provider_user)
    provider_user = FactoryBot.create(:provider_user, providers: [provider])
    permissions = ProviderPermissions::VALID_PERMISSIONS.map(&:to_s).sample(3)

    ProviderMailer.permissions_granted(provider_user, provider, permissions, permissions_granted_by_user)
  end

  def permissions_granted_by_support
    provider = FactoryBot.create(:provider)
    provider_user = FactoryBot.create(:provider_user, providers: [provider])
    permissions = ProviderPermissions::VALID_PERMISSIONS.map(&:to_s).sample(3)

    ProviderMailer.permissions_granted(provider_user, provider, permissions, nil)
  end

  def permissions_removed
    provider = FactoryBot.create(:provider)
    permissions_revoked_by_user = FactoryBot.create(:provider_user)
    provider_user = FactoryBot.create(:provider_user, providers: [provider])

    ProviderMailer.permissions_removed(provider_user, provider, permissions_revoked_by_user)
  end

  def permissions_removed_by_support
    provider = FactoryBot.create(:provider)
    provider_user = FactoryBot.create(:provider_user, providers: [provider])

    ProviderMailer.permissions_removed(provider_user, provider)
  end

  def permissions_updated
    provider = FactoryBot.create(:provider)
    permissions_updated_by_user = FactoryBot.create(:provider_user)
    provider_user = FactoryBot.create(:provider_user, providers: [provider])
    permissions = ProviderPermissions::VALID_PERMISSIONS.map(&:to_s).sample(3)

    ProviderMailer.permissions_updated(provider_user, provider, permissions, permissions_updated_by_user)
  end

  def permissions_updated__all_permissions_removed
    provider = FactoryBot.create(:provider)
    permissions_updated_by_user = FactoryBot.create(:provider_user)
    provider_user = FactoryBot.create(:provider_user, providers: [provider])
    permissions = []

    ProviderMailer.permissions_updated(provider_user, provider, permissions, permissions_updated_by_user)
  end

  def permissions_updated_by_support
    provider = FactoryBot.create(:provider)
    provider_user = FactoryBot.create(:provider_user, providers: [provider])
    permissions = ProviderPermissions::VALID_PERMISSIONS.map(&:to_s).sample(3)

    ProviderMailer.permissions_updated(provider_user, provider, permissions, nil)
  end

  def set_up_organisation_permissions
    relationships_to_set_up = {
      'University of Dundee' => ['University of Broughty Ferry', 'University of Forfar', 'University of Wormit'],
      'University of Selsdon' => ['University of Croydon', 'University of Purley'],
    }
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.set_up_organisation_permissions(provider_user, relationships_to_set_up)
  end

  def set_up_organisation_permissions_single_provider_one_relationship
    relationships_to_set_up = {
      'University of Dundee' => ['University of Broughty Ferry'],
    }
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.set_up_organisation_permissions(provider_user, relationships_to_set_up)
  end

  def set_up_organisation_permissions_single_provider_multiple_relationships
    relationships_to_set_up = {
      'University of Dundee' => ['University of Broughty Ferry', 'University of Forfar', 'University of Wormit'],
    }
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.set_up_organisation_permissions(provider_user, relationships_to_set_up)
  end
end
