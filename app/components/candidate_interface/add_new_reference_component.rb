module CandidateInterface
  class AddNewReferenceComponent < ViewComponent::Base
    include AddNewReferenceHelpers

    attr_reader :current_application, :editable_section
    alias application_form current_application

    def initialize(current_application:, editable_section:)
      @current_application = current_application
      @editable_section = editable_section
    end
  end
end
