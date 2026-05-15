class ProcessStaleApplicationsWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :default

  def perform
    ProcessStaleApplications.new.call
  end
end
