# This worker will be scheduled to run nightly
class RejectApplicationsByDefaultWorker
  include Sidekiq::Worker

  def perform(*)
    RejectApplicationsByDefault.new.call
  end
end
