module CandidateInterface
  class AfterSignInController < CandidateInterfaceController
    def interstitial
      course = current_candidate.course_from_find

      current_candidate.update!(course_from_find_id: nil) if course.present?

      if current_application.contains_course?(course)
        flash[:warning] = "You have already selected #{course.name_and_code}."
        redirect_to candidate_interface_course_choices_review_path
      elsif current_application.has_the_maximum_number_of_course_choices?
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
