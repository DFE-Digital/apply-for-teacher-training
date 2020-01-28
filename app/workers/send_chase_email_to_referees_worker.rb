class SendChaseEmailToRefereesWorker
  include Sidekiq::Worker

  def perform
    GetRefereesToChase.call.each do |choice|
      begin
        SendChaseEmail.new(application_choice: choice).call
      rescue StandardError => e
        Rails.logger.warn "[DBD] ignoring application_choice #{choice.id}: #{e.message}"
      end
    end
  end
end
