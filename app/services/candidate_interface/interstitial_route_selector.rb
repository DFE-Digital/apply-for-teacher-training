module CandidateInterface
  class InterstitialRouteSelector
    attr_accessor :candidate,
                  :candidate_already_has_3_courses,
                  :candidate_has_new_course_added,
                  :candidate_should_choose_site,
                  :candidate_does_not_have_a_course_from_find,
                  :candidate_has_already_selected_the_course,
                  :candidate_has_submitted_application,
                  :candidate_should_choose_study_mode

    def initialize(candidate:)
      @candidate = candidate
      @candidate_already_has_3_courses = false
      @candidate_has_new_course_added = false
      @candidate_should_choose_site = false
      @candidate_does_not_have_a_course_from_find = false
      @candidate_has_already_selected_the_course = false
      @candidate_has_submitted_application = false
    end

    def execute
      if !has_course_from_find?
        @candidate_does_not_have_a_course_from_find = true
        return
      end

      if candidate.current_application.submitted?
        set_course_from_find_id_to_nil
        @candidate_has_submitted_application = true
        return
      end

      if candidate_already_has_3_courses?
        @candidate_already_has_3_courses = true
      elsif candidate_has_already_selected_the_course?
        @candidate_has_already_selected_the_course = true
      elsif course_has_both_study_modes?
        set_course_from_find_id_to_nil
        @candidate_should_choose_study_mode = true
      elsif course_has_one_site?
        @candidate_has_new_course_added = true
      else
        @candidate_should_choose_site = true
      end
      set_course_from_find_id_to_nil
    end

  private

    def set_course_from_find_id_to_nil
      @candidate.update!(course_from_find_id: nil)
    end

    def has_course_from_find?
      @candidate.course_from_find_id.present?
    end

    def course_has_one_site?
      CourseOption.where(course_id: @candidate.course_from_find_id).one?
    end

    def candidate_already_has_3_courses?
      @candidate.current_application.application_choices.count >= 3
    end

    def candidate_has_already_selected_the_course?
      potential_course_option_ids_for_course_from_find = CourseOption.where(course_id: @candidate.course_from_find_id).map(&:id)
      current_course_option_ids = @candidate.current_application.application_choices.map(&:course_option_id)

      (potential_course_option_ids_for_course_from_find & current_course_option_ids).present?
    end

    def course_has_both_study_modes?
      Course.find(@candidate.course_from_find_id).both_study_modes_available?
    end
  end
end
