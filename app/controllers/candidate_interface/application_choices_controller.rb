module CandidateInterface
  class ApplicationChoicesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def index
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

      current_application.update!(course_choices_completed: false)

      redirect_to candidate_interface_course_choices_index_path
    end

    def review
      @application_form = current_application
      @application_choices = current_candidate.current_application.application_choices
    end

    def complete
      @application_form = current_application

      render :index if @application_form.application_choices.count.zero?

      if @application_form.update(application_form_params)
        redirect_to candidate_interface_application_form_path
      else
        @application_choices = current_candidate.current_application.application_choices
        track_validation_error(@application_form)

        render :review
      end
    end

  private

    def current_course_choice_id
      params.permit(:id)[:id]
    end

    def application_form_params
      params.require(:application_form).permit(:course_choices_completed)
    end
  end
end
