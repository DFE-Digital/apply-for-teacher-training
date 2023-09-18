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
        application_choice.rejection_reasons_type = structured_rejection_reasons.blank? ? :rejection_reason : structured_rejection_reasons.class.name.underscore
        application_choice.reject_by_default_feedback_sent_at = Time.zone.now
        application_choice.save!
      end

      show_apply_again_guidance = unsuccessful_application_choices? && not_applied_again?

      unless application_choice.continuous_applications?
        CandidateMailer.feedback_received_for_application_rejected_by_default(application_choice, show_apply_again_guidance).deliver_later
      end

      notify_slack
    end
  end

  def notify_slack
    provider_name = application_choice.current_course.provider.name
    candidate_name = application_form.first_name
    message = ":telephone_receiver: #{provider_name} has sent feedback for #{candidate_name}’s RBD application"
    url = Rails.application.routes.url_helpers.support_interface_application_form_url(application_form)

    SlackNotificationWorker.perform_async(message, url)
  end

private

  def not_applied_again?
    application_form.subsequent_application_form.nil?
  end

  def unsuccessful_application_choices?
    application_form
      .application_choices
      .map(&:status)
      .all? { |status| ApplicationStateChange::UNSUCCESSFUL_STATES.include?(status.to_sym) }
  end

  def application_form
    @application_form ||= application_choice.application_form
  end

  delegate :candidate, to: :application_form
end
