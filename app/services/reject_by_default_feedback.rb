class RejectByDefaultFeedback
  include ImpersonationAuditHelper

  attr_reader :application_choice, :rejection_reason, :structured_rejection_reasons

  def initialize(actor:, application_choice:, rejection_reason: nil, structured_rejection_reasons: nil)
    @actor = actor
    @application_choice = application_choice
    @rejection_reason = rejection_reason
    @structured_rejection_reasons = structured_rejection_reasons
  end

  def save
    audit(@actor) do
      ActiveRecord::Base.transaction do
        application_choice.rejection_reason = rejection_reason
        application_choice.structured_rejection_reasons = structured_rejection_reasons
        application_choice.reject_by_default_feedback_sent_at = Time.zone.now
        application_choice.save!
      end

      CandidateMailer.feedback_received_for_application_rejected_by_default(application_choice).deliver_later
      notify_slack
    end
  end

  def notify_slack
    provider_name = application_choice.current_course.provider.name
    candidate_name = application_choice.application_form.first_name
    message = ":telephone_receiver: #{provider_name} has sent feedback for #{candidate_name}’s RBD application"
    url = Rails.application.routes.url_helpers.support_interface_application_form_url(application_choice.application_form)

    SlackNotificationWorker.perform_async(message, url)
  end
end
