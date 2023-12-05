module Chasers
  module Candidate
    class OfferEmailService
      def self.call(application_choice:, mailer:, chaser_type:)
        CandidateMailer.send(mailer, application_choice).deliver_now
        ChaserSent.create!(chased: application_choice, chaser_type:)
      end
    end
  end
end
