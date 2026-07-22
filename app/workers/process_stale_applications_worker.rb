class ProcessStaleApplicationsWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform
    ProcessStaleApplications.new.call
  end
end
