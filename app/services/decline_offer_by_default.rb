class DeclineOfferByDefault
  attr_accessor :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_choices = []

    ActiveRecord::Base.transaction do
      application_form.application_choices.offer.each do |application_choice|
        application_choice.update!(declined_by_default: true, declined_at: Time.zone.now)
        ApplicationStateChange.new(application_choice).decline_by_default!
        application_choices << application_choice
      end
    end

    application_choices.each do |application_choice|
      NotificationsList.for(application_choice).each do |provider_user|
        ProviderMailer.declined_by_default(provider_user, application_choice).deliver_later
        Metrics::Tracker.new(application_choice, 'notifications.on', provider_user).track(:offer_declined_by_default)
      end

      NotificationsList.off_for(application_choice).each do |provider_user|
        Metrics::Tracker.new(application_choice, 'notifications.off', provider_user).track(:offer_declined_by_default)
      end
    end

    CandidateMailer.declined_by_default(application_form).deliver_later
  end
end
