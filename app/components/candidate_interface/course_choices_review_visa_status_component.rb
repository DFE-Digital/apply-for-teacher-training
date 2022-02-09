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
      ) || (
        !@application_choice.course.salary? &&
        @application_choice.provider.can_sponsor_student_visa?
      )
    end

    def title
      if can_sponsor_visa?
        'Visas can be sponsored'
      else
        'Visa sponsorship is not available for this course'
      end
    end
  end
end
