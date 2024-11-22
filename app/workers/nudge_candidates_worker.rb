# This worker will be scheduled to run daily
class NudgeCandidatesWorker
  include Sidekiq::Worker

  Nudge = Struct.new(:query_class, :mailer_action)
  NUDGES = [
    Nudge.new(
      GetUnsubmittedApplicationsReadyToNudge,
      :nudge_unsubmitted,
    ),
    Nudge.new(
      GetIncompleteCourseChoiceApplicationsReadyToNudge,
      :nudge_unsubmitted_with_incomplete_courses,
    ),
    Nudge.new(
      GetIncompletePersonalStatementApplicationsReadyToNudge,
      :nudge_unsubmitted_with_incomplete_personal_statement,
    ),
    Nudge.new(
      GetIncompleteReferenceApplicationsReadyToNudge,
      :nudge_unsubmitted_with_incomplete_references,
    ),
  ].freeze

  def perform
    NUDGES.each do |nudge|
      nudge.query_class.new.call.each do |application_form|
        send_nudge(nudge.mailer_action, application_form)
      end
    end
  end

  # This method can be run manually via a Rails console to perform a dry-run to
  # see who will be sent a nudge email without actually sending anything.
  def dry_run(nudge)
    nudge.query_class.new.call.find_each do |application_form|
      puts "Sending email for application form #{Rails.application.routes.url_helpers.support_interface_application_form_url(application_form.id)}"
    end
  end

private

  def send_nudge(mailer_action, application_form)
    CandidateMailer.send(mailer_action, application_form).deliver_later
  end
end
