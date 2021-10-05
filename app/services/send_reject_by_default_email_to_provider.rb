class SendRejectByDefaultEmailToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.rejected?

    NotificationsList.for(application_choice, event: :application_rejected_by_default).each do |provider_user|
      can_make_decisions = provider_user.authorisation.can_make_decisions?(application_choice: application_choice,
                                                                           course_option: application_choice.current_course_option)
      ProviderMailer.application_rejected_by_default(provider_user, application_choice, can_make_decisions: can_make_decisions).deliver_later
    end
  end
end
