# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariantsDailyCheck
  include Sidekiq::Worker

  def perform
    detect_applications_with_course_choices_in_previous_cycle
    detect_application_choices_with_courses_from_the_incorrect_cycle
    detect_submitted_applications_with_more_than_the_max_course_choices
    detect_application_choices_with_out_of_date_provider_ids
    detect_obsolete_feature_flags
    detect_if_the_monthly_statistics_has_not_run
    detect_submitted_applications_with_more_than_the_max_unsuccessful_choices
  end

  def detect_if_the_monthly_statistics_has_not_run
    return unless HostingEnvironment.production?
    return if MonthlyStatisticsTimetable.current_generation_date.after? Time.zone.now

    latest_monthly_report = Publications::MonthlyStatistics::MonthlyStatisticsReport.last

    return if latest_monthly_report.nil? || latest_monthly_report.generation_date >= MonthlyStatisticsTimetable.current_generation_date

    latest_month = MonthlyStatisticsTimetable.last_publication_date.strftime('%B')

    message = "The monthly statistics report has not been generated for #{latest_month}"
    Sentry.capture_exception(MonthlyStatisticsReportHasNotRun.new(message))
  end

  def detect_applications_with_course_choices_in_previous_cycle
    forms_with_last_years_courses = ApplicationChoice
      .joins(:application_form, course_option: [:course])
      .where('extract(year from application_forms.submitted_at) = ?', RecruitmentCycleTimetable.current_year)
      .where(courses: { recruitment_cycle_year: RecruitmentCycleTimetable.previous_year })
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

  def detect_submitted_applications_with_more_than_the_max_course_choices
    applications_with_too_many_choices = ApplicationForm
      .joins(:application_choices)
      .where(application_choices: { status: (ApplicationStateChange::DECISION_PENDING_STATUSES + ApplicationStateChange::ACCEPTED_STATES + ApplicationStateChange::SUCCESSFUL_STATES) })
      .group('application_forms.id')
      .having("count(application_choices) > #{ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES}")
      .sort

    if applications_with_too_many_choices.any?
      urls = applications_with_too_many_choices.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have been submitted with more than #{ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES.humanize} course choices

        #{urls.join("\n")}
      MSG

      Sentry.capture_exception(SubmittedApplicationHasMoreThanTheMaxCourseChoices.new(message))
    end
  end

  def detect_submitted_applications_with_more_than_the_max_unsuccessful_choices
    # Why this total? They could have all their course choices rejected
    # Then they will have that many more than the max number of unsuccessful applications
    total_number_of_possible_unsuccessful_applications =
      ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS +
      ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES - 1
    applications_with_too_many_unsuccessful_choices = ApplicationForm
      .current_cycle
      .joins(:application_choices)
      .where(application_choices: { status: (ApplicationStateChange::UNSUCCESSFUL_STATES - %i[inactive]) })
      .group('application_forms.id')
      .having("count(application_choices) > #{total_number_of_possible_unsuccessful_applications.to_i}")
      .sort

    if applications_with_too_many_unsuccessful_choices.any?
      urls = applications_with_too_many_unsuccessful_choices.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have been submitted with more than #{total_number_of_possible_unsuccessful_applications.humanize} unsuccessful course choices

        #{urls.join("\n")}
      MSG

      Sentry.capture_exception(SubmittedApplicationHasMoreThanTheMaxUnsuccessfulCourseChoices.new(message))
    end
  end

  def detect_application_choices_with_out_of_date_provider_ids
    out_of_date_choices = FindApplicationChoicesWithOutOfDateProviderIds.call

    if out_of_date_choices.present?
      message = "Out-of-date application choices: #{out_of_date_choices.map(&:id).sort.join(', ')}"
      Sentry.capture_exception(ApplicationChoicesWithOutOfDateProviderIds.new(message))
    end
  end

  def detect_obsolete_feature_flags
    feature_names = FeatureFlag::FEATURES.map(&:first)
    obsolete_features = Feature.where.not(name: feature_names).order(:name)

    return if obsolete_features.none?

    message = 'The following obsolete feature flags have yet to be deleted from the database: ' \
              "#{obsolete_features.map(&:name).sort.to_sentence}"
    Sentry.capture_exception(ObsoleteFeatureFlags.new(message))
  end

  class ApplicationHasCourseChoiceInPreviousCycle < StandardError; end
  class ApplicationWithADifferentCyclesCourse < StandardError; end
  class ApplicationSubmittedWithMoreThanTwoSelectedReferences < StandardError; end
  class SubmittedApplicationHasMoreThanTheMaxCourseChoices < StandardError; end
  class ApplicationChoicesWithOutOfDateProviderIds < StandardError; end
  class ObsoleteFeatureFlags < StandardError; end
  class MonthlyStatisticsReportHasNotRun < StandardError; end
  class SubmittedApplicationHasMoreThanTheMaxUnsuccessfulCourseChoices < StandardError; end

private

  def helpers
    Rails.application.routes.url_helpers
  end
end
