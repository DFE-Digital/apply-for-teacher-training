# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariantsDailyCheck
  include Sidekiq::Worker

  def perform
    detect_outstanding_references_on_submitted_applications
    detect_applications_with_course_choices_in_previous_cycle
    detect_application_choices_with_courses_from_the_incorrect_cycle
    detect_submitted_applications_with_more_than_two_selected_references
    detect_applications_submitted_with_the_same_course
    detect_submitted_applications_with_more_than_three_course_choices
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

  def detect_application_choices_with_courses_from_the_incorrect_cycle
    applications_choices_with_invalid_courses = ApplicationChoice
    .joins(:application_form, current_course_option: [:course])
    .where('courses.recruitment_cycle_year != application_forms.recruitment_cycle_year')
    .where(offer_deferred_at: nil)

    if applications_choices_with_invalid_courses.any?
      urls = applications_choices_with_invalid_courses
      .map(&:application_form)
      .uniq
      .map { |application_form| helpers.support_interface_application_form_url(application_form.id) }

      message = <<~MSG
        The following applications have an application choice with a course from a different recruitment cycle

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationWithADifferentCyclesCourse.new(message))
    end
  end

  def detect_submitted_applications_with_more_than_two_selected_references
    applications_with_more_than_two_selected_references = ApplicationForm
    .joins(:application_references)
    .where.not(submitted_at: nil)
    .where(references: { selected: true })
    .group('references.application_form_id')
    .having('COUNT("references".id) > 2')
    .pluck(:application_form_id).uniq
    .sort

    if applications_with_more_than_two_selected_references.any?
      urls = applications_with_more_than_two_selected_references.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following applications have been submitted with more than two selected references

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationSubmittedWithMoreThanTwoSelectedReferences.new(message))
    end
  end

  def detect_applications_submitted_with_the_same_course
    applications_with_the_same_choice = ApplicationForm
      .joins(application_choices: [:course_option])
      .where.not(submitted_at: nil)
      .where.not('application_choices.status': %w[withdrawn rejected])
      .group('application_forms.id', 'course_options.course_id')
      .having('COUNT(DISTINCT course_options.course_id) < COUNT(application_choices.id)')

    if applications_with_the_same_choice.any?
      urls = applications_with_the_same_choice.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following applications have been submitted containing the same course choice multiple times

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationSubmittedWithTheSameCourse.new(message))
    end
  end

  def detect_submitted_applications_with_more_than_three_course_choices
    applications_with_too_many_choices = ApplicationForm
      .joins(:application_choices)
      .where(application_choices: { status: (ApplicationStateChange::DECISION_PENDING_STATUSES + ApplicationStateChange::ACCEPTED_STATES) })
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

  class OutstandingReferencesOnSubmittedApplication < StandardError; end
  class ApplicationHasCourseChoiceInPreviousCycle < StandardError; end
  class ApplicationWithADifferentCyclesCourse < StandardError; end
  class ApplicationSubmittedWithMoreThanTwoSelectedReferences < StandardError; end
  class ApplicationSubmittedWithTheSameCourse < StandardError; end
  class SubmittedApplicationHasMoreThanThreeChoices < StandardError; end

private

  def helpers
    Rails.application.routes.url_helpers
  end
end
