module CandidateInterface
  class AfterSignInController < CandidateInterfaceController
    before_action :redirect_to_prefill_if_sandbox_user_has_blank_application
    before_action :redirect_to_path_if_path_params_are_present
    before_action :redirect_to_application_form_unless_course_from_find_is_present

    def interstitial
      current_candidate.update!(course_from_find_id: nil)

      if current_application.submitted?
        redirect_to candidate_interface_application_complete_path
      elsif current_application.contains_course?(course_from_find)
        flash[:warning] = "You have already selected #{course_from_find.name_and_code}."
        redirect_to candidate_interface_course_choices_review_path
      elsif current_application.maximum_number_of_course_choices?
        error_message_key = current_application.apply_1? ? 'errors.messages.too_many_course_choices' : 'errors.messages.apply_again_course_already_chosen'
        flash[:warning] = I18n.t(error_message_key, course_name_and_code: course_from_find.name_and_code)

        redirect_to candidate_interface_course_choices_review_path
      else
        redirect_to candidate_interface_course_confirm_selection_path(course_from_find.id)
      end
    end

  private

    def redirect_to_path_if_path_params_are_present
      redirect_to params[:path] if params[:path].present?
    end

    def redirect_to_prefill_if_sandbox_user_has_blank_application
      if HostingEnvironment.sandbox_mode? && current_application.blank_application?
        if course_from_find
          key = "prefill_application_#{current_user.id}"
          value = { course_id: course_from_find.id }

          Rails.cache.write(key, value, expires_in: 5.minutes)
        end

        redirect_to candidate_interface_prefill_path
      else
        false
      end
    end

    def redirect_to_application_form_unless_course_from_find_is_present
      return false unless course_from_find.nil?

      if current_application.blank_application?
        redirect_to candidate_interface_before_you_start_path
      elsif current_application.submitted?
        redirect_to candidate_interface_application_complete_path
      else
        redirect_to candidate_interface_application_form_path
      end
    end

    def course_from_find
      @course_from_find ||= current_candidate.course_from_find
    end
  end
end
