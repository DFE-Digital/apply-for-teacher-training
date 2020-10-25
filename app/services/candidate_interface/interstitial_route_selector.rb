module CandidateInterface
  class InterstitialRouteSelector
    attr_accessor :candidate,
                  :candidate_already_has_3_courses,
                  :candidate_has_already_selected_the_course

    def initialize(candidate:)
      @candidate = candidate
      @candidate_already_has_3_courses = false
      @candidate_has_already_selected_the_course = false
    end

    def execute
      if candidate_already_has_3_courses?
        @candidate_already_has_3_courses = true
      elsif candidate_has_already_selected_the_course?
        @candidate_has_already_selected_the_course = true
      end

      set_course_from_find_id_to_nil
    end

  private

    def set_course_from_find_id_to_nil
      @candidate.update!(course_from_find_id: nil)
    end

    def candidate_already_has_3_courses?
      @candidate.current_application.application_choices.count >= 3
    end

    def candidate_has_already_selected_the_course?
      potential_course_option_ids_for_course_from_find = CourseOption.where(course_id: @candidate.course_from_find_id).map(&:id)
      current_course_option_ids = @candidate.current_application.application_choices.map(&:course_option_id)

      (potential_course_option_ids_for_course_from_find & current_course_option_ids).present?
    end
  end
end
