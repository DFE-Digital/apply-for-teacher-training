module CandidateInterface
  class AfterSignInController < CandidateInterfaceController
    def interstitial
      course = current_candidate.course_from_find

      service = InterstitialRouteSelector.new(candidate: current_candidate)
      service.execute

      current_candidate.update!(course_from_find_id: nil) if course.present?

      if service.candidate_has_already_selected_the_course
        flash[:warning] = "You have already selected #{course.name_and_code}."
        redirect_to candidate_interface_course_choices_review_path
      elsif service.candidate_already_has_3_courses
        flash[:warning] = I18n.t('errors.messages.too_many_course_choices', course_name_and_code: course.name_and_code)
        redirect_to candidate_interface_course_choices_review_path
      elsif course.present?
        redirect_to candidate_interface_course_confirm_selection_path(course.id)
      elsif current_application.blank_application?
        redirect_to candidate_interface_before_you_start_path
      else
        redirect_to candidate_interface_application_form_path
      end
    end
  end
end
