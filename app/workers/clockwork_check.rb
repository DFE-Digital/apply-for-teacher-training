class ClockworkCheck
  include Sidekiq::Worker

  def perform(*args)
    Rails.logger.info "clockwork is running..."
  end
end
