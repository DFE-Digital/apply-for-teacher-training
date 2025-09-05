module CandidateInterface
  class AddNewReferenceComponent < ApplicationComponent
    include AddNewReferenceHelpers

    attr_reader :current_application, :section_policy
    alias application_form current_application

    def initialize(current_application:, section_policy:)
      @current_application = current_application
      @section_policy = section_policy
    end
  end
end
