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

    def edit
      @application_feedback = current_application.application_feedback.find(params[:id])
      @application_feedback_form = CandidateInterface::ApplicationFeedbackForm.new
    end

    def update
      @application_feedback = current_application.application_feedback.find(params[:id])
      @application_feedback_form = CandidateInterface::ApplicationFeedbackForm.new(update_params)

      if @application_feedback_form.update(@application_feedback)
        redirect_to candidate_interface_application_feedback_thank_you_path
      else
        track_validation_error(@application_feedback_form)
        render :edit
      end
    end

    def thank_you
      @application_feedback = current_application.application_feedback.last
      @previous_path = if @application_feedback.id_in_path
                         Rails.application.routes.url_helpers.send(@application_feedback.path, @application_feedback.id_in_path)
                       else
                         Rails.application.routes.url_helpers.send(@application_feedback.path)
                       end
    end

  private

    def create_params
      {
        section: params[:section],
        path: params[:path],
        page_title: params[:page_title],
        issues: params[:issues],
        id_in_path: params[:id_in_path],
      }
    end

    def update_params
      params.require(:candidate_interface_application_feedback_form).permit(
        :does_not_understand_section, :need_more_information, :answer_does_not_fit_format,
        :other_feedback, :consent_to_be_contacted
      )
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
