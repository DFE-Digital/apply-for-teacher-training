class SendChaseEmailToRefereesWorker
  include Sidekiq::Worker

  def perform
    GetRefereesToChase.new.perform.each do |reference|
      begin
        SendChaseEmail.new.perform(refence: reference)
      rescue StandardError => e
        Rails.logger.warn "[5 day referee chase email] ignoring reference #{reference.id}: #{e.message}"
      end
    end
  end
end
