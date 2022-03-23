# This worker will be scheduled to run daily
class NudgeUnsubmittedCandidatesWorker
  include Sidekiq::Worker

  def perform
    return unless FeatureFlag.active?(:candidate_nudge_emails)

    GetUnsubmittedApplicationsReadyToNudge.new.call.each do |application_form|
      send_nudge(application_form)
    end
  end

private

  def send_nudge(application_form)
    CandidateMailer.nudge_unsubmitted(application_form).deliver_later
  end
end
