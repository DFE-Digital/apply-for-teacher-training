class SaveAndSendRejectByDefaultFeedback
  attr_reader :rejection_reason

  def initialize(application_choice:, rejection_reason:)
    @application_choice = application_choice
    @rejection_reason = rejection_reason
  end

  def call
    @application_choice.rejection_reason = rejection_reason
    @application_choice.reject_by_default_feedback_sent_at = Time.zone.now
    @application_choice.save
  end
end
