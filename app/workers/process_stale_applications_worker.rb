class ProcessStaleApplicationsWorker < ApplicationJob
  def perform
    ProcessStaleApplications.new.call
  end
end
