# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariantsDailyCheck
  include Sidekiq::Worker

  def perform
    detect_outstanding_references_on_submitted_applications
    detect_applications_with_course_choices_in_previous_cycle
    detect_application_choices_with_courses_from_the_incorrect_cycle
    detect_submitted_applications_with_more_than_two_selected_references
    detect_submitted_applications_with_more_than_three_course_choices
    detect_application_choices_with_out_of_date_provider_ids
    detect_obsolete_feature_flags
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

      Sentry.capture_exception(OutstandingReferencesOnSubmittedApplication.new(message))
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

      Sentry.capture_exception(ApplicationHasCourseChoiceInPreviousCycle.new(message))
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

      Sentry.capture_exception(ApplicationWithADifferentCyclesCourse.new(message))
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

      Sentry.capture_exception(ApplicationSubmittedWithMoreThanTwoSelectedReferences.new(message))
    end
  end

  def detect_submitted_applications_with_more_than_three_course_choices
    applications_with_too_many_choices = ApplicationForm
      .joins(:application_choices)
      .where(application_choices: { status: (ApplicationStateChange::DECISION_PENDING_STATUSES + ApplicationStateChange::ACCEPTED_STATES + ApplicationStateChange::SUCCESSFUL_STATES) })
      .group('application_forms.id')
      .having('count(application_choices) > 3')
      .sort

    if applications_with_too_many_choices.any?
      urls = applications_with_too_many_choices.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have been submitted with more than three course choices

        #{urls.join("\n")}
      MSG

      Sentry.capture_exception(SubmittedApplicationHasMoreThanThreeChoices.new(message))
    end
  end

  def detect_application_choices_with_out_of_date_provider_ids
    out_of_date_choices = FindApplicationChoicesWithOutOfDateProviderIds.call

    if out_of_date_choices.present?
      message = "Out-of-date application choices: #{out_of_date_choices.map(&:id).join(', ')}"
      Sentry.capture_exception(ApplicationChoicesWithOutOfDateProviderIds.new(message))
    end
  end

  def detect_obsolete_feature_flags
    feature_names = FeatureFlag::FEATURES.map(&:first)
    obsolete_features = Feature.where.not(name: feature_names)

    return if obsolete_features.none?

    message = 'The following obsolete feature flags have yet to be deleted from the database: '  \
              "#{obsolete_features.map(&:name).to_sentence}"
    Sentry.capture_exception(ObsoleteFeatureFlags.new(message))
  end

  class OutstandingReferencesOnSubmittedApplication < StandardError; end
  class ApplicationHasCourseChoiceInPreviousCycle < StandardError; end
  class ApplicationWithADifferentCyclesCourse < StandardError; end
  class ApplicationSubmittedWithMoreThanTwoSelectedReferences < StandardError; end
  class SubmittedApplicationHasMoreThanThreeChoices < StandardError; end
  class ApplicationChoicesWithOutOfDateProviderIds < StandardError; end
  class ObsoleteFeatureFlags < StandardError; end

private

  def helpers
    Rails.application.routes.url_helpers
  end
end
