class ProviderMailerPreview < ActionMailer::Preview
  def reference_received
    reference = FactoryBot.create(:reference, :feedback_provided)
    course = FactoryBot.build_stubbed(:course, provider:)
    ProviderMailer.reference_received(reference:, application_choice:, provider_user:, course:)
  end

  def confirm_sign_in
    ProviderMailer.confirm_sign_in(
      FactoryBot.build_stubbed(:provider_user),
      timestamp: Time.zone.now,
    )
  end

  def application_submitted
    ProviderMailer.application_submitted(provider_user, application_choice)
  end

  def application_submitted_with_safeguarding_issues
    ProviderMailer.application_submitted_with_safeguarding_issues(provider_user, application_choice)
  end

  def offer_accepted
    ProviderMailer.offer_accepted(provider_user, application_choice)
  end

  def declined_by_default
    ProviderMailer.declined_by_default(provider_user, application_choice)
  end

  def application_withdrawn_no_interviews
    ProviderMailer.application_withdrawn(provider_user, application_choice, 0)
  end

  def application_withdrawn_with_interviews
    ProviderMailer.application_withdrawn(provider_user, application_choice, rand(2..4))
  end

  def declined
    ProviderMailer.declined(provider_user, application_choice)
  end

  def fallback_sign_in_email
    ProviderMailer.fallback_sign_in_email(
      FactoryBot.build_stubbed(:provider_user),
      token: 'ABC-FOO',
    )
  end

  def unconditional_offer_accepted
    ProviderMailer.unconditional_offer_accepted(provider_user, application_choice)
  end

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

  def apply_service_is_now_open
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.apply_service_is_now_open(provider_user)
  end

  def find_service_is_now_open
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.find_service_is_now_open(provider_user)
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

  def reminder_respond_to_applications_before_reject_by_default_date
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.reminder_respond_to_applications_before_reject_by_default_date(provider_user)
  end

private

  def provider
    @provider ||= FactoryBot.create(:provider)
  end

  def site
    @site ||= FactoryBot.create(:site, code: '-', name: 'Main site', provider:)
  end

  def application_choice
    course = FactoryBot.create(:course, provider:)
    course_option = FactoryBot.create(:course_option, course:, site:)
    FactoryBot.create(:application_choice, :awaiting_provider_decision, :with_completed_application_form, course_option:, course:)
  end

  def provider_user
    FactoryBot.build(:provider_user)
  end
end
