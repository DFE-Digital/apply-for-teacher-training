# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariants
  include Sidekiq::Worker

  def perform
    detect_application_choices_in_old_states
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

  class WeirdSituationDetected < StandardError; end
end
