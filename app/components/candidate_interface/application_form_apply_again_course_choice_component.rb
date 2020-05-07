module CandidateInterface
  class ApplicationFormApplyAgainCourseChoiceComponent < ViewComponent::Base
    def initialize(completed:)
      @completed = completed
    end

    attr_reader :completed
    alias_method :completed?, :completed

    def view_courses_path
      if completed?
        candidate_interface_application_review_path
      else
        candidate_interface_course_choices_index_path
      end
    end

    def course_choice_title
      I18n.t!('page_titles.course_choice')
    end
  end
end
