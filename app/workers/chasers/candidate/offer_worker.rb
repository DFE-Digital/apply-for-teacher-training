module Chasers
  module Candidate
    class OfferWorker
      include Sidekiq::Worker

      DAYS_TO_CHASER_MAPPING = {
        10 => :offer_10_day,
        20 => :offer_20_day,
        30 => :offer_30_day,
        40 => :offer_40_day,
        50 => :offer_50_day,
      }.freeze

      def perform
        OffersToChaseQuery::VALID_INTERVALS.each do |days|
          chaser_type = mailer = DAYS_TO_CHASER_MAPPING.fetch(days)

          OffersToChaseQuery.call(days:).find_each do |application_choice|
            Chasers::Candidate::OfferEmailService.call(mailer:, chaser_type:, application_choice:)
          end
        end
      end
    end
  end
end
