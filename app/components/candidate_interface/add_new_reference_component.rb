module CandidateInterface
  class AddNewReferenceComponent < ViewComponent::Base
    include AddNewReferenceHelpers

    attr_reader :current_application, :section_policy
    alias application_form current_application

    def initialize(current_application:, section_policy:, reference_process:)
      @current_application = current_application
      @section_policy = section_policy
      @reference_process = reference_process
    end
  end
end
