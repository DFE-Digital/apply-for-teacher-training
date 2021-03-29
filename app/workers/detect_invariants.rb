# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariants
  include Sidekiq::Worker

  def perform
    detect_application_choices_in_old_states
    detect_outstanding_references_on_submitted_applications
    detect_unauthorised_application_form_edits
    detect_applications_with_course_choices_in_previous_cycle
    detect_submitted_applications_with_more_than_three_course_choices
  end

  def detect_application_choices_in_old_states
    choices_in_wrong_state = begin
      ApplicationChoice.where(status: %w[awaiting_references application_complete]).map(&:id).sort
    end

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

  def detect_outstanding_references_on_submitted_applications
    applications_with_reference_weirdness = ApplicationChoice
      .joins(application_form: [:application_references])
      .where.not(application_choices: { status: 'unsubmitted' })
      .where(references: { feedback_status: :feedback_requested })
      .pluck(:application_form_id).uniq
      .sort

    if applications_with_reference_weirdness.any?
      urls = applications_with_reference_weirdness.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        One or more references are still pending on these applications,
        even though they've already been submitted:

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(OutstandingReferencesOnSubmittedApplication.new(message))
    end
  end

  def detect_unauthorised_application_form_edits
    unauthorised_changes = Audited::Audit
      .joins("INNER JOIN application_forms ON application_forms.id = audits.associated_id AND audits.associated_type = 'ApplicationForm'")
      .joins('INNER JOIN candidates ON candidates.id = application_forms.candidate_id')
      .where(audits: { user_type: 'Candidate' })
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

  def detect_applications_with_course_choices_in_previous_cycle
    forms_with_last_years_courses = ApplicationChoice
      .joins(:application_form, course_option: [:course])
      .where('extract(year from application_forms.submitted_at) = ?', RecruitmentCycle.current_year)
      .where(courses: { recruitment_cycle_year: RecruitmentCycle.previous_year })
      .pluck(:application_form_id).uniq
      .sort

    if forms_with_last_years_courses.any?
      urls = forms_with_last_years_courses.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have course choices from the previous recruitment cycle

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationHasCourseChoiceInPreviousCycle.new(message))
    end
  end

  def detect_submitted_applications_with_more_than_three_course_choices
    applications_with_too_many_choices = ApplicationForm
      .joins(:application_choices)
      .where.not(application_choices: { status: 'unsubmitted' })
      .group('application_forms.id')
      .having('count(application_choices) > 3')
      .sort

    if applications_with_too_many_choices.any?
      urls = applications_with_too_many_choices.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have been submitted with more than three course choices

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(SubmittedApplicationHasMoreThanThreeChoices.new(message))
    end
  end

  class ApplicationInRemovedState < StandardError; end
  class OutstandingReferencesOnSubmittedApplication < StandardError; end
  class ApplicationEditedByWrongCandidate < StandardError; end
  class ApplicationHasCourseChoiceInPreviousCycle < StandardError; end
  class SubmittedApplicationHasMoreThanThreeChoices < StandardError; end

private

  def helpers
    Rails.application.routes.url_helpers
  end
end
