module CandidateInterface
  class MissingRightToWorkInsetComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:)
      @application_form = application_form
    end
  end
end
