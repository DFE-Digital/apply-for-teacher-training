module ProviderInterface
  class SendCandidateWithdrawnOnRequestEmail
    attr_reader :application_choice, :helper

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def call
      CandidateMailer.application_withdrawn_on_request(application_choice).deliver_later
    end
  end
end
