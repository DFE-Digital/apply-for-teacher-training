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
      CandidateMailer.application_withdrawn_on_request_offers_only(application_choice).deliver_later
    end
  end
end
