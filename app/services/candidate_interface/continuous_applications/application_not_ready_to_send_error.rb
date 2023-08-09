module CandidateInterface
  module ContinuousApplications
    class ApplicationNotReadyToSendError < StandardError
      attr_reader :application_choice

      def initialize(application_choice)
        @application_choice = application_choice
      end

      def message
        "Tried to send an application in the #{application_choice.status} state to a provider"
      end
    end
  end
end
