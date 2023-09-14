class DeclineOfferByDefault
  attr_accessor :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_choices = []

    ActiveRecord::Base.transaction do
      application_form.application_choices.offer.each do |application_choice|
        application_choice.update!(
          declined_by_default: true,
          declined_at: Time.zone.now,
          withdrawn_or_declined_for_candidate_by_provider: false,
        )
        ApplicationStateChange.new(application_choice).decline_by_default!
        application_choices << application_choice
      end
    end

    unless application_form.continuous_applications?
      application_choices.each do |application_choice|
        NotificationsList.for(application_choice, event: :declined_by_default, include_ratifying_provider: true).each do |provider_user|
          ProviderMailer.declined_by_default(provider_user, application_choice).deliver_later
        end
      end

      CandidateMailer.declined_by_default(application_form).deliver_later
    end
  end
end
