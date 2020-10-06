class SendNewApplicationEmailToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.awaiting_provider_decision?

    application_choice.provider.provider_users.each do |provider_user|
      if application_choice.application_form.has_safeguarding_issues_to_declare?
        ProviderMailer.application_submitted_with_safeguarding_issues(provider_user, application_choice).deliver_later
      else
        ProviderMailer.application_submitted(provider_user, application_choice).deliver_later
      end
    end
  end
end
