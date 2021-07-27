class ProviderMailerPreview < ActionMailer::Preview
  def confirm_sign_in
    ProviderMailer.confirm_sign_in(
      FactoryBot.build_stubbed(:provider_user),
      device: {
        ip_address: Faker::Internet.ip_v4_address,
        user_agent: Faker::Internet.user_agent,
      },
    )
  end

  def account_created_email
    ProviderMailer.account_created(provider_user)
  end

  def application_submitted
    ProviderMailer.application_submitted(provider_user, application_choice)
  end

  def application_submitted_with_safeguarding_issues
    ProviderMailer.application_submitted_with_safeguarding_issues(provider_user, application_choice)
  end

  def application_rejected_by_default
    ProviderMailer.application_rejected_by_default(provider_user, application_choice)
  end

  def chase_provider_decision
    choice = application_choice
    choice.update(reject_by_default_at: 20.business_days.from_now)
    ProviderMailer.chase_provider_decision(provider_user, choice)
  end

  def offer_accepted
    ProviderMailer.offer_accepted(provider_user, application_choice)
  end

  def declined_by_default
    ProviderMailer.declined_by_default(provider_user, application_choice)
  end

  def application_withdrawn
    ProviderMailer.application_withdrawn(provider_user, application_choice)
  end

  def declined
    ProviderMailer.declined(provider_user, application_choice)
  end

  def ucas_match_initial_email_duplicate_applications
    ProviderMailer.ucas_match_initial_email_duplicate_applications(provider_user, application_choice)
  end

  def ucas_match_resolved_on_ucas_email
    ProviderMailer.ucas_match_resolved_on_ucas_email(provider_user, application_choice)
  end

  def ucas_match_resolved_on_apply_email
    ProviderMailer.ucas_match_resolved_on_apply_email(provider_user, application_choice)
  end

  def fallback_sign_in_email
    ProviderMailer.fallback_sign_in_email(
      FactoryBot.build_stubbed(:provider_user),
      token: 'ABC-FOO',
    )
  end

  def courses_open_on_apply
    ProviderMailer.courses_open_on_apply(
      FactoryBot.build_stubbed(:provider_user),
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
      training_provider: training_provider,
      ratifying_provider: ratifying_provider,
      ratifying_provider_can_make_decisions: true,
      training_provider_can_view_safeguarding_information: false,
      ratifying_provider_can_view_safeguarding_information: true,
      ratifying_provider_can_view_diversity_information: true,
    )
    ProviderMailer.organisation_permissions_set_up(provider_user, permissions)
  end

  def organisation_permissions_updated
    training_provider = FactoryBot.create(:provider)
    ratifying_provider = FactoryBot.create(:provider)
    provider_user = FactoryBot.create(:provider_user, providers: [ratifying_provider])
    provider_user.provider_permissions.update_all(manage_organisations: true)
    permissions = FactoryBot.create(
      :provider_relationship_permissions,
      training_provider: training_provider,
      ratifying_provider: ratifying_provider,
      ratifying_provider_can_make_decisions: true,
      training_provider_can_make_decisions: false,
      ratifying_provider_can_view_safeguarding_information: true,
    )
    ProviderMailer.organisation_permissions_updated(provider_user, permissions)
  end

private

  def provider
    @provider ||= FactoryBot.create(:provider)
  end

  def site
    @site ||= FactoryBot.create(:site, code: '-', name: 'Main site', provider: provider)
  end

  def application_choice
    course = FactoryBot.create(:course, provider: provider)
    course_option = FactoryBot.create(:course_option, course: course, site: site)
    FactoryBot.create(:submitted_application_choice, :with_completed_application_form, course_option: course_option, course: course)
  end

  def provider_user
    FactoryBot.build :provider_user
  end
end
