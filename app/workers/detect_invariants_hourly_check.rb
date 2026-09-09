class DetectInvariantsHourlyCheck < ApplicationJob
  def perform
    detect_course_sync_not_succeeded_for_an_hour unless HostingEnvironment.review?
    detect_unauthorised_application_form_edits
    detect_unconfirmed_vendors
  end

  def detect_unauthorised_application_form_edits
    unauthorised_changes = Audited::Audit
      .joins("INNER JOIN application_forms ON audits.associated_type = 'ApplicationForm' AND application_forms.id = audits.associated_id")
      .joins('INNER JOIN candidates ON candidates.id = application_forms.candidate_id')
      .where('audits.created_at > ?', 7.days.ago)
      .where(user_type: 'Candidate', associated_type: 'ApplicationForm')
      .where('candidates.id != audits.user_id')
      .pluck('application_forms.id').uniq
      .sort

    if unauthorised_changes.any?
      urls = unauthorised_changes.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have had edits by a candidate who is not the owner of the application:

        #{urls.join("\n")}
      MSG

      Sentry.capture_exception(ApplicationEditedByWrongCandidate.new(message))
    end
  end

  def detect_course_sync_not_succeeded_for_an_hour
    unless TeacherTrainingPublicAPI::SyncCheck.check
      Sentry.capture_exception(
        CourseSyncNotSucceededForAnHour.new(
          'The course sync via the Teacher training public API has not succeeded for an hour',
        ),
      )
    end
  end

  def detect_unconfirmed_vendors
    unconfirmed_vendors = Vendor.unconfirmed.ids

    if unconfirmed_vendors.any?
      Sentry.capture_exception(
        UnconfirmedVendorsError.new(
          "The vendors with ids #{unconfirmed_vendors} have been created by providers, we need to confirm if they are real vendors",
        ),
      )
    end
  end

  class ApplicationEditedByWrongCandidate < StandardError; end
  class CourseSyncNotSucceededForAnHour < StandardError; end
  class UnconfirmedVendorsError < StandardError; end

private

  def helpers
    Rails.application.routes.url_helpers
  end
end
