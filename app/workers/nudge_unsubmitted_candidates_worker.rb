# This worker will be scheduled to run daily
class NudgeUnsubmittedCandidatesWorker
  include Sidekiq::Worker

  def perform
    return unless FeatureFlag.active?(:candidate_nudge_emails)

    GetUnsubmittedApplicationsReadyToNudge.new.call.each do |application_form|
      send_nudge(application_form)
    end
  end

  # This method can be run manually via a Rails console to perform a dry-run to
  # see who will be sent a nudge email without actually sending anything.
  # It can be deleted when the `candidate_nudge_emails` feature flag is deleted.
  def dry_run
    GetUnsubmittedApplicationsReadyToNudge.new.call.find_each do |application_form|
      # rubocop:disable Rails/Output
      puts "Sending email for application form #{Rails.application.routes.url_helpers.support_interface_application_form_url(application_form.id)}"
      # rubocop:enable Rails/Output
    end
  end

private

  def send_nudge(application_form)
    CandidateMailer.nudge_unsubmitted(application_form).deliver_later
  end
end
