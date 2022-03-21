# This worker will be scheduled to run daily
class NudgeUnsubmittedCandidatesWorker
  include Sidekiq::Worker

  def perform
    GetUnsubmittedApplicationsReadyToNudge.call.each do |application_form|
      send_nudge(application_form)
    end
  end

private

  def send_nudge(application_form)
  end
end
