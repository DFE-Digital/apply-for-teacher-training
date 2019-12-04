# This worker will be scheduled to run nightly
class DeclineOffersByDefaultWorker
  include Sidekiq::Worker

  def perform
    GetApplicationChoicesReadyToDeclineByDefault.call.each do |choice|
      begin
        DeclineOfferByDefault.new(application_choice: choice).call
      rescue StandardError => e
        Rails.logger.warn "[DBD] ignoring application_choice #{choice.id}: #{e.message}"
      end
    end
  end
end
