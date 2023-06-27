class RejectApplicationsByDefaultWorker
  include Sidekiq::Worker

  def perform
    RejectApplicationsByDefault.new.call
  end
end
