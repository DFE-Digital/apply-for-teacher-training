module CandidateInterface
  class ApplicationChoicesController < SectionController
    before_action :redirect_to_dashboard_if_submitted
    skip_before_action :verify_authorized_section

    def confirm_destroy
      @course_choice = current_candidate.current_application.application_choices.find(params[:id])
    end

    def destroy
      application_choice = current_application
        .application_choices
        .find(current_course_choice_id)

      CandidateInterface::DeleteApplicationChoice.new(application_choice:).call

      if current_application.application_choices.any?
        redirect_to candidate_interface_course_choices_review_path
      else
        redirect_to candidate_interface_course_choices_choose_path
      end
    end

    def review
      @application_form = current_application
      @application_choices = current_candidate.current_application.application_choices
      @section_complete_form = SectionCompleteForm.new(completed: current_application.course_choices_completed)
    end

    def complete
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(form_params)

      redirect_to candidate_interface_course_choices_choose_path and return if @application_form.application_choices.count.zero?

      if @section_complete_form.save(current_application, :course_choices_completed)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        render :review
      end
    end

  private

    def current_course_choice_id
      params.permit(:id)[:id]
    end

    def form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end
