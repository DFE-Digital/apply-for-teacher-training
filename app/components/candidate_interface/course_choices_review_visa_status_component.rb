module CandidateInterface
  class CourseChoicesReviewVisaStatusComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_choice:)
      @application_choice = application_choice
    end
  end
end
