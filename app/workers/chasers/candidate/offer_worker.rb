module Chasers
  module Candidate
    class OfferWorker
      include Sidekiq::Worker

      def perform
        Chasers::Candidate.chaser_to_date_range.each do |chaser_type, date_range|
          mailer = chaser_type

          OffersToChaseQuery.call(chaser_type:, date_range:).find_each do |application_choice|
            Chasers::Candidate::OfferEmailService.call(mailer:, chaser_type:, application_choice:)
          end
        end
      end
    end
  end
end
