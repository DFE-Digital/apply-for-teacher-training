class SaveAndSendRejectByDefaultFeedback
  attr_reader :application_choice, :rejection_reason

  def initialize(application_choice:, rejection_reason:)
    @application_choice = application_choice
    @rejection_reason = rejection_reason
  end

  def call!
    ActiveRecord::Base.transaction do
      application_choice.rejection_reason = rejection_reason
      application_choice.reject_by_default_feedback_sent_at = Time.zone.now
      application_choice.save!

      CandidateMailer.feedback_received_for_application_rejected_by_default(application_choice).deliver_later
    end
  end
end
