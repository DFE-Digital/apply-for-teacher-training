# This worker will be scheduled to run nightly
class SendApplicationsToProviderWorker
  include Sidekiq::Worker

  def perform(*)
    SendApplicationsToProvider.new.call
  end
end
