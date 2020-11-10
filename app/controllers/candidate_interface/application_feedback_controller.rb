module CandidateInterface
  class ApplicationFeedbackController < CandidateInterfaceController
    def create
      @application_feedback_form = CandidateInterface::ApplicationFeedbackForm.new(create_params)

      if @application_feedback_form.save(current_application)
        if @application_feedback_form.has_issues?
          redirect_to candidate_interface_edit_application_feedback_path(
            current_application.application_feedback.last.id,
          )
        else
          redirect_to candidate_interface_application_feedback_thank_you_path
        end
      else
        track_validation_error(@references_relationship_form)
        flash[:warning] = add_errors_to_flash_message

        redirect_to previous_path
      end
    end

    def edit; end

    def update; end

    def thank_you; end

  private

    def create_params
      {
        section: params[:section],
        path: params[:path],
        page_title: params[:page_title],
        issues: params[:issues],
      }
    end

    def previous_path
      request.env['HTTP_REFERER']
    end

    def add_errors_to_flash_message
      @application_feedback_form
      .errors
      .messages
      .values
      .flatten
      .join('\n')
    end
  end
end
