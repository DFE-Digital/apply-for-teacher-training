class WithdrawApplication
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(application_choice).withdraw!
      application_choice.update!(withdrawn_at: Time.zone.now)
      SetDeclineByDefault.new(application_form: application_choice.application_form).call

      StateChangeNotifier.call(:withdraw, application_choice: application_choice)
      send_email_notification_to_provider_users(application_choice)
    end
  end

private

  attr_reader :application_choice

  def send_email_notification_to_provider_users(application_choice)
    application_choice.provider.provider_users.each do |provider_user|
      ProviderMailer.application_withrawn(provider_user, application_choice).deliver
    end
  end
end
