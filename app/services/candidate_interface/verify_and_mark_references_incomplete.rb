module CandidateInterface
  class VerifyAndMarkReferencesIncomplete
    attr_reader :current_application

    def initialize(current_application)
      @current_application = current_application
    end

    def call
      current_application.update!(references_completed: false) if !current_application.complete_references_information? && current_application.references_completed?
    end
  end
end
