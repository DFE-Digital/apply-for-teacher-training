module CandidateInterface
  class AfterSignInController < CandidateInterfaceController
    before_action :redirect_to_prefill_if_sandbox_user_has_blank_application
    before_action :redirect_to_path_if_path_params_are_present
    before_action :redirect_to_application_form_unless_course_from_find_is_present

    def interstitial
      current_candidate.update!(course_from_find_id: nil)

      if current_application.submitted? && !current_application.continuous_applications?
        redirect_to candidate_interface_application_complete_path
      elsif current_application.contains_course?(course_from_find)
        flash[:warning] = "You have already added an application for #{course_from_find.name}. #{view_context.link_to('Find a different course to apply to', find_url, class: 'govuk-link')}."
        redirect_to course_choices_page
      elsif current_application.maximum_number_of_course_choices?
        flash[:warning] = I18n.t('errors.messages.too_many_course_choices', max_applications: ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES, course_name: course_from_find.name)
        redirect_to course_choices_page
      elsif current_application.reached_maximum_unsuccessful_choices?
        flash[:warning] = I18n.t('errors.messages.too_many_unsuccessful_choices', max_unsuccessful_applications: ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS)

        redirect_to course_choices_page
      else
        redirect_to confirm_selection_page
      end
    end

  private

    def course_choices_page
      candidate_interface_continuous_applications_choices_path
    end

    def confirm_selection_page
      candidate_interface_continuous_applications_course_confirm_selection_path(course_from_find.id)
    end

    def redirect_to_path_if_path_params_are_present
      redirect_to params[:path] if params[:path].present?
    end

    def redirect_to_prefill_if_sandbox_user_has_blank_application
      if HostingEnvironment.sandbox_mode? && current_application.blank_application?
        store_prefill_data if course_from_find

        redirect_to candidate_interface_prefill_path
      else
        false
      end
    end

    def redirect_to_application_form_unless_course_from_find_is_present
      return false unless course_from_find.nil?

      if current_application.submitted?
        redirect_to candidate_interface_application_complete_path
      else
        redirect_to candidate_interface_continuous_applications_details_path
      end
    end

    def course_from_find
      @course_from_find ||= current_candidate.course_from_find
    end

    def store_prefill_data
      store = PrefillApplicationStateStore::RailsCache.new(current_user.id)
      data = { course_id: course_from_find.id }
      store.write(data)
    end
  end
end
