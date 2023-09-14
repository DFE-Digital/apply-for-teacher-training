# This worker will be scheduled to run daily
class NudgeCandidatesWorker
  include Sidekiq::Worker

  Nudge = Struct.new(:query_class, :mailer_action, :feature_flag)
  NUDGES = [
    Nudge.new(
      GetUnsubmittedApplicationsReadyToNudge,
      :nudge_unsubmitted,
      nil,
    ),
    Nudge.new(
      GetIncompleteCourseChoiceApplicationsReadyToNudge,
      :nudge_unsubmitted_with_incomplete_courses,
      nil,
    ),
    Nudge.new(
      GetIncompletePersonalStatementApplicationsReadyToNudge,
      :nudge_unsubmitted_with_incomplete_personal_statement,
      nil,
    ),
    Nudge.new(
      GetIncompleteReferenceApplicationsReadyToNudge,
      :nudge_unsubmitted_with_incomplete_references,
      :reference_nudges,
    ),
  ].freeze

  def perform
    NUDGES.each do |nudge|
      next unless nudge.feature_flag.nil? || FeatureFlag.active?(nudge.feature_flag)

      nudge.query_class.new.call.each do |application_form|
        send_nudge(nudge.mailer_action, application_form)
      end
    end
  end

  # This method can be run manually via a Rails console to perform a dry-run to
  # see who will be sent a nudge email without actually sending anything.
  def dry_run(nudge)
    nudge.query_class.new.call.find_each do |application_form|
      # rubocop:disable Rails/Output
      puts "Sending email for application form #{Rails.application.routes.url_helpers.support_interface_application_form_url(application_form.id)}"
      # rubocop:enable Rails/Output
    end
  end

private

  def send_nudge(mailer_action, application_form)
    CandidateMailer.send(mailer_action, application_form).deliver_later
  end
end
