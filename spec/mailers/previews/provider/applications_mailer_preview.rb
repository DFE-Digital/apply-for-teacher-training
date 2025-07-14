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

  def unconditional_offer_accepted
    ProviderMailer.unconditional_offer_accepted(provider_user, application_choice)
  end

  def declined
    ProviderMailer.declined(provider_user, application_choice)
  end

  def declined_by_default
    ProviderMailer.declined_by_default(provider_user, application_choice)
  end

  def offer_accepted
    ProviderMailer.offer_accepted(provider_user, application_choice)
  end
end
