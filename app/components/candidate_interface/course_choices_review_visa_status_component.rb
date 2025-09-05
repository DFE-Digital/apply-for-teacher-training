module CandidateInterface
  class CourseChoicesReviewVisaStatusComponent < ApplicationComponent
    include ViewHelper

    def initialize(application_choice:)
      @application_choice = application_choice
    end
  end
end
