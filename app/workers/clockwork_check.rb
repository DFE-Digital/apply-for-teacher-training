class ClockworkCheck
  include Sidekiq::Worker

  def perform(*)
    Rails.logger.info 'clockwork is running...'
  end
end
