module CandidateInterface
  class RespondToOfferForm
    include ActiveModel::Model
    attr_accessor :response
    validates :response, presence: true

    def decline?
      response == 'decline'
    end

    def accept?
      response == 'accept'
    end
  end
end
