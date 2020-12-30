class DeclineOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ApplicationStateChange.new(@application_choice).decline!
    @application_choice.update!(declined_at: Time.zone.now)
    StateChangeNotifier.call(:offer_declined, application_choice: @application_choice)

    if @application_choice.application_form.ended_without_success?
      CandidateMailer.decline_last_application_choice(@application_choice).deliver_later
    end

    NotificationsList.for(@application_choice).each do |provider_user|
      ProviderMailer.declined(provider_user, @application_choice).deliver_later
      Metrics::Tracker.new(@application_choice, 'notifications.on', provider_user).track(:offer_declined)
    end

    NotificationsList.off_for(@application_choice).each do |provider_user|
      Metrics::Tracker.new(@application_choice, 'notifications.off', provider_user).track(:offer_declined)
    end
  end
end
