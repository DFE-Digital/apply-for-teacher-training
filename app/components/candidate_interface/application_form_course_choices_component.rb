module CandidateInterface
  class ApplicationFormCourseChoicesComponent < ViewComponent::Base
    def initialize(choices_are_present:, completed:)
      @choices_are_present = choices_are_present
      @completed = completed
    end

    attr_reader :choices_are_present, :completed
    alias completed? completed
    alias choices_are_present? choices_are_present

    def view_courses_path
      if completed?
        candidate_interface_course_choices_review_path
      else
        candidate_interface_course_choices_index_path
      end
    end
  end
end
