class ProviderMailerPreview < ActionMailer::Preview
  def account_created_email
    ProviderMailer.account_created(provider_user)
  end

  def application_submitted
    ProviderMailer.application_submitted(provider_user, application_choice)
  end

  def application_rejected_by_default
    ProviderMailer.application_rejected_by_default(provider_user, application_choice)
  end

  def chase_provider_decision_after_twenty_working_days
    ProviderMailer.chase_provider_decision(provider_user, application_choice)
  end

  def offer_accepted
    ProviderMailer.offer_accepted(provider_user, application_choice)
  end

  def declined_by_default
    ProviderMailer.declined_by_default(provider_user, application_choice)
  end

  def application_withdrawn
    # TODO: replace with the correct method call once application_withrawn is gone
    ProviderMailer.application_withrawn(provider_user, application_choice)
  end

  def declined
    ProviderMailer.declined(provider_user, application_choice)
  end

  def application_submitted_over_5_days_ago
    ProviderMailer.application_submitted_over_5_days_ago(provider_user, application_choice)
  end

  def application_submitted_with_safeguarding
    ProviderMailer.application_submitted_with_safeguarding(provider_user, application_choice)
  end

  def fallback_sign_in_email
    ProviderMailer.fallback_sign_in_email(
      FactoryBot.build_stubbed(:provider_user),
      token: 'ABC-FOO',
    )
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
    FactoryBot.create(:submitted_application_choice, course_option: course_option, course: course)
  end

  def provider_user
    FactoryBot.build :provider_user
  end
end
