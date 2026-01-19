module CandidateInterface
  class AddNewReferenceComponent < ViewComponent::Base
    include AddNewReferenceHelpers

    attr_reader :current_application
    alias application_form current_application

    def initialize(current_application:)
      @current_application = current_application
    end
  end
end
