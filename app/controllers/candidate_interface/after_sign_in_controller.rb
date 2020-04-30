module CandidateInterface
  class AfterSignInController < CandidateInterfaceController
    def interstitial
      course = current_candidate.course_from_find

      service = InterstitialRouteSelector.new(candidate: current_candidate)
      service.execute

      if service.candidate_does_not_have_a_course_from_find || service.candidate_has_submitted_application
        if more_reference_needed?
          redirect_to candidate_interface_additional_referee_path
        elsif current_candidate.current_application.blank_application?
          redirect_to candidate_interface_before_you_start_path
        else
          redirect_to candidate_interface_application_form_path
        end
      elsif service.candidate_has_already_selected_the_course
        flash[:warning] = "You have already selected #{course.name_and_code}."
        redirect_to candidate_interface_course_choices_review_path
      elsif service.candidate_already_has_3_courses
        flash[:warning] = I18n.t('errors.messages.too_many_course_choices', course_name_and_code: course.name_and_code)
        redirect_to candidate_interface_course_choices_review_path
      elsif !service.candidate_does_not_have_a_course_from_find
        redirect_to candidate_interface_course_confirm_selection_path(course_id: course.id)
      elsif service.candidate_should_choose_site
        redirect_to candidate_interface_course_choices_site_path(course.provider.id, course.id, course.study_mode)
      elsif service.candidate_should_choose_study_mode
        redirect_to candidate_interface_course_choices_study_mode_path(course.provider.id, course.id)
      end
    end
  end
end
