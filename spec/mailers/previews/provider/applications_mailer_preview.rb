class Provider::ApplicationsMailerPreview < ActionMailer::Preview
  def application_submitted
    ProviderMailer.application_submitted(provider_user, application_choice)
  end

  def application_submitted_with_safeguarding_issues
    ProviderMailer.application_submitted_with_safeguarding_issues(provider_user, application_choice)
  end

  def application_withdrawn_no_interviews
    ProviderMailer.application_withdrawn(provider_user, application_choice, 0)
  end

  def application_withdrawn_with_interviews
    ProviderMailer.application_withdrawn(provider_user, application_choice, rand(2..4))
  end

  def application_auto_withdrawn_on_accept_offer
    ProviderMailer.application_auto_withdrawn_on_accept_offer(provider_user, application_choice)
  end

  def unconditional_offer_accepted
    ProviderMailer.unconditional_offer_accepted(provider_user, application_choice)
  end

  def declined
    ProviderMailer.declined(provider_user, application_choice)
  end

  def declined_automatically_on_accept_offer
    ProviderMailer.declined_automatically_on_accept_offer(provider_user, application_choice)
  end

  def declined_by_default
    ProviderMailer.declined_by_default(provider_user, application_choice)
  end

  def offer_accepted
    ProviderMailer.offer_accepted(provider_user, application_choice)
  end

private

  def provider
    @provider ||= FactoryBot.build_stubbed(:provider)
  end

  def site
    @site ||= FactoryBot.build_stubbed(:site, code: '-', name: 'Main site', provider:)
  end

  def application_choice
    course = FactoryBot.build_stubbed(:course, provider:)
    course_option = FactoryBot.build_stubbed(:course_option, course:, site:)
    FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision, :with_completed_application_form, course_option:, course:)
  end

  def provider_user
    FactoryBot.build(:provider_user)
  end
end
