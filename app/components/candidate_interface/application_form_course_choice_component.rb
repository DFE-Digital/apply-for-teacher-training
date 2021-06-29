module CandidateInterface
  class ApplicationFormCourseChoiceComponent < ViewComponent::Base
    def initialize(completed:)
      @completed = completed
    end

    attr_reader :completed
    alias completed? completed

    def view_courses_path
      if completed?
        candidate_interface_application_review_path
      else
        candidate_interface_course_choices_index_path
      end
    end
  end
end
