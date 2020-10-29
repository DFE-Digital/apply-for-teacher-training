# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariants
  include Sidekiq::Worker

  def perform
    detect_application_choices_in_old_states
    detect_outstanding_references_on_submitted_applications
  end

  def detect_application_choices_in_old_states
    choices_in_wrong_state = begin
      ApplicationChoice.where(status: %w[awaiting_references application_complete])
    end

    if choices_in_wrong_state.any?
      message = <<~MSG
        One or more application choices are still in `awaiting_references` or
        `application_complete` state, but all these states have been removed:

        #{choices_in_wrong_state.map(&:id).join("\n")}
      MSG

      Raven.capture_exception(WeirdSituationDetected.new(message))
    end
  end

  def detect_outstanding_references_on_submitted_applications
    applications_with_reference_weirdness = ApplicationChoice
      .joins(application_form: [:application_references])
      .where.not(application_choices: { status: 'unsubmitted' })
      .where(references: { feedback_status: :feedback_requested })
      .pluck(:application_form_id).uniq

    if applications_with_reference_weirdness.any?
      message = <<~MSG
        One or more references are still pending on these applications,
        even though they've already been submitted:
        #{applications_with_reference_weirdness.join("\n")}
      MSG

      Raven.capture_exception(WeirdSituationDetected.new(message))
    end
  end

  class WeirdSituationDetected < StandardError; end
end
