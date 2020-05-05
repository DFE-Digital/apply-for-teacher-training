class WithdrawApplication
  def initialize(application_choice:)
    @application_choice = application_choice
    @application_choices = application_choice.application_form.application_choices
  end

  def save!
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(application_choice).withdraw!
      application_choice.update!(withdrawn_at: Time.zone.now)
      SetDeclineByDefault.new(application_form: application_choice.application_form).call

      if @application_choice.application_form.ended_without_success? && FeatureFlag.active?('apply_again')
        CandidateMailer.withdraw_last_application_choice(@application_choice.application_form).deliver_later
      end
    end

    StateChangeNotifier.call(:withdraw, application_choice: application_choice)
    send_email_notification_to_provider_users(application_choice)
  end

private

  attr_reader :application_choice

  def send_email_notification_to_provider_users(application_choice)
    application_choice.provider.provider_users.each do |provider_user|
      ProviderMailer.application_withrawn(provider_user, application_choice).deliver_later
    end
  end
end
