class ProcessStaleApplicationsWorker
  include Sidekiq::Worker

  def perform
    ProcessStaleApplications.new.call
  end
end
