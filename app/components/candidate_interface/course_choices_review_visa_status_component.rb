module CandidateInterface
  class CourseChoicesReviewVisaStatusComponent < BaseComponent
    include ViewHelper

    def initialize(application_choice:)
      @application_choice = application_choice
    end
  end
end
