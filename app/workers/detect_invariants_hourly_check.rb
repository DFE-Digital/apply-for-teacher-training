# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariantsHourlyCheck
  include Sidekiq::Worker

  def perform
    detect_course_sync_not_succeeded_for_an_hour
    detect_high_sidekiq_retries_queue_length
    detect_unauthorised_application_form_edits
    detect_application_choices_in_old_states
  end

  def detect_application_choices_in_old_states
    choices_in_wrong_state =
      ApplicationChoice
      .where("status IN ('awaiting_references', 'application_complete')")
      .map(&:id).sort

    if choices_in_wrong_state.any?
      urls = choices_in_wrong_state.map { |application_choice_id| helpers.support_interface_application_choice_url(application_choice_id) }

      message = <<~MSG
        One or more application choices are still in `awaiting_references` or
        `application_complete` state, but all these states have been removed:

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationInRemovedState.new(message))
    end
  end

  def detect_unauthorised_application_form_edits
    unauthorised_changes = Audited::Audit
      .joins("INNER JOIN application_forms ON audits.associated_type = 'ApplicationForm' AND application_forms.id = audits.associated_id")
      .joins('INNER JOIN candidates ON candidates.id = application_forms.candidate_id')
      .where(user_type: 'Candidate')
      .where('candidates.id != audits.user_id')
      .pluck('application_forms.id').uniq
      .sort

    if unauthorised_changes.any?
      urls = unauthorised_changes.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have had edits by a candidate who is not the owner of the application:

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationEditedByWrongCandidate.new(message))
    end
  end

  def detect_course_sync_not_succeeded_for_an_hour
    unless TeacherTrainingPublicAPI::SyncCheck.check
      Raven.capture_exception(
        CourseSyncNotSucceededForAnHour.new(
          'The course sync via the Teacher training public API has not succeeded for an hour',
        ),
      )
    end
  end

  def detect_high_sidekiq_retries_queue_length
    retries_queue_length = Sidekiq::RetrySet.new.size
    if retries_queue_length > 50
      Raven.capture_exception(
        SidekiqRetriesQueueHigh.new(
          "Sidekiq pending retries depth is high (#{retries_queue_length}). Suggests high error rate",
        ),
      )
    end
  end

  class ApplicationInRemovedState < StandardError; end
  class ApplicationEditedByWrongCandidate < StandardError; end
  class CourseSyncNotSucceededForAnHour < StandardError; end
  class SidekiqRetriesQueueHigh < StandardError; end

private

  def helpers
    Rails.application.routes.url_helpers
  end
end
