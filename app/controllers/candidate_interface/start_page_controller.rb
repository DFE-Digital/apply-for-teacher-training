module CandidateInterface
  class StartPageController < CandidateInterfaceController
    before_action :show_pilot_holding_page_if_not_open
    skip_before_action :authenticate_candidate!
    before_action :redirect_signed_in_candidate

    def show; end

    def eligibility
      @eligibility_form = EligibilityForm.new
    end

    def determine_eligibility
      @eligibility_form = EligibilityForm.new(eligibility_params)

      if !@eligibility_form.valid?
        render :eligibility
      elsif @eligibility_form.eligible_to_use_dfe_apply?
        redirect_to candidate_interface_sign_up_path(providerCode: params[:providerCode], courseCode: params[:courseCode])
      else
        redirect_to candidate_interface_not_eligible_path
      end
    end

    def eligibility_params
      params.fetch(:candidate_interface_eligibility_form, {}).permit(:eligible_citizen, :eligible_qualifications)
        .transform_values(&:strip)
    end

  private

    def redirect_signed_in_candidate
      if current_candidate.present?
        add_course_from_find_id_to_candidate if params[:providerCode].present?

        service = ExistingCandidateAuthentication.new(candidate: current_candidate)
        service.execute

        if service.candidate_does_not_have_a_course_from_find || service.candidate_has_submitted_application
          redirect_to candidate_interface_interstitial_path
        elsif service.candidate_has_already_selected_the_course
          flash[:warning] = "You have already selected #{@course.name_and_code}."
          redirect_to candidate_interface_course_choices_review_path
        elsif service.candidate_has_new_course_added
          redirect_to candidate_interface_course_choices_review_path
        elsif service.candidate_should_choose_site
          redirect_to candidate_interface_course_choices_site_path(@course.provider.code, @course.code)
        elsif service.candidate_already_has_3_courses
          flash[:warning] = "You cannot have more than 3 course choices. You must delete a choice if you want to apply to #{@course.name_and_code}."
          redirect_to candidate_interface_course_choices_review_path
        else
          redirect_to candidate_interface_application_form_path
        end
      end
    end

    def add_course_from_find_id_to_candidate
      provider = Provider.find_by(code: params[:providerCode])
      @course = provider.courses.find_by(code: params[:courseCode]) if provider.present?
      current_candidate.update!(course_from_find_id: @course.id) if @course.present?
    end
  end
end
