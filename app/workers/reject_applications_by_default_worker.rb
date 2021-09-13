# This worker will be scheduled to run nightly
class RejectApplicationsByDefaultWorker
  include Sidekiq::Worker
  include SafePerformAsync

  def perform
    RejectApplicationsByDefault.new.call
  end
end
