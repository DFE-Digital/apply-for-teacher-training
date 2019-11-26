# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariants
  include Sidekiq::Worker

  def perform
    detect_application_choices_stuck_in_awaiting_references_state
  end

  def detect_application_choices_stuck_in_awaiting_references_state
    # Application choices with completed feedback, but still awaiting references
    choices_in_wrong_state = begin
      ApplicationChoice.where(status: 'awaiting_references', application_form: ApplicationForm.includes(:references).select(&:references_complete?))
    end

    if choices_in_wrong_state.any?
      message = <<~MSG
        One or more application choices in `awaiting_references` state, but all feedback is collected:

        #{choices_in_wrong_state.map(&:id).join('\n')}
      MSG

      Raven.capture_exception(WeirdSituationDetected.new(message))
    end
  end

  class WeirdSituationDetected < StandardError; end
end
