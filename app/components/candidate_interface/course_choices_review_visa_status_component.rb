module CandidateInterface
  class CourseChoicesReviewVisaStatusComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_choice:)
      @application_choice = application_choice
    end

  private

    def can_sponsor_visa?
      (
        @application_choice.course.salary? &&
        @application_choice.provider.can_sponsor_skilled_worker_visa?
      ) ||
      (
        !@application_choice.course.salary? &&
        @application_choice.provider.can_sponsor_student_visa?
      )
    end

    def title
      if can_sponsor_visa?
        'Visas can be sponsored'
      elsif @application_choice.course.salary?
        'This provider cannot sponsor Skilled Worker visas'
      else
        'This provider cannot sponsor Student visas'
      end
    end
  end
end
