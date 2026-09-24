class SendNewApplicationEmailToProvider
  attr_accessor :application_choice, :wait_time

  def initialize(application_choice:, wait_time: nil)
    self.application_choice = application_choice
    self.wait_time = wait_time
  end

  def call
    return false unless application_choice.awaiting_provider_decision?

    if wait_time.nil?
      NotificationsList.for(application_choice, event: :application_submitted, include_ratifying_provider: true).each do |provider_user|
        if application_choice.application_form.has_safeguarding_issues_to_declare?
          ProviderMailer.application_submitted_with_safeguarding_issues(provider_user, application_choice).deliver_later
        else
          ProviderMailer.application_submitted(provider_user, application_choice).deliver_later
        end
      end
    else
      NotificationsList.for(application_choice, event: :application_submitted, include_ratifying_provider: true).each do |provider_user|
        if application_choice.application_form.has_safeguarding_issues_to_declare?
          ProviderMailer.application_submitted_with_safeguarding_issues(provider_user, application_choice).deliver_later(wait: wait_time)
        else
          ProviderMailer.application_submitted(provider_user, application_choice).deliver_later(wait: wait_time)
        end
      end
    end
  end
end
