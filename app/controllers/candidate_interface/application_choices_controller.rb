module CandidateInterface
  class ApplicationChoicesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def index
      redirect_to candidate_interface_application_form_path and return unless CycleTimetable.can_add_course_choice?(current_application)

      @application_choices = current_candidate.current_application.application_choices

      if @application_choices.any?
        redirect_to candidate_interface_course_choices_review_path
      end
    end

    def confirm_destroy
      @course_choice = current_candidate.current_application.application_choices.find(params[:id])
    end

    def destroy
      current_application
        .application_choices
        .find(current_course_choice_id)
        .destroy!

      current_application.update!(course_choices_completed: nil) if current_application.application_choices.empty?

      redirect_to candidate_interface_course_choices_index_path
    end

    def review
      @application_form = current_application
      @application_choices = current_candidate.current_application.application_choices
      @section_complete_form = SectionCompleteForm.new(completed: current_application.course_choices_completed)
    end

    def complete
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(form_params)

      render :index and return if @application_form.application_choices.count.zero?

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
