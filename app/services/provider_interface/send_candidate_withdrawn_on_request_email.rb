module ProviderInterface
  class SendCandidateWithdrawnOnRequestEmail
    include CandidateApplications

    attr_reader :application_choice, :helper

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def call
      if application_choice.continuous_applications?
        CandidateMailer.application_withdrawn_on_request(application_choice).deliver_later
      else
        pre_continuous_applications_withdrawn_mailers
      end
    end

  private

    def pre_continuous_applications_withdrawn_mailers
      if applications_with_offer_and_awaiting_decision?
        CandidateMailer.application_withdrawn_on_request_one_offer_one_awaiting_decision(application_choice).deliver_later
      elsif applications_awaiting_decision_only?
        CandidateMailer.application_withdrawn_on_request_awaiting_decision_only(application_choice).deliver_later
      elsif applications_with_offers_only?
        CandidateMailer.application_withdrawn_on_request_offers_only(application_choice).deliver_later
      end
    end
  end
end
