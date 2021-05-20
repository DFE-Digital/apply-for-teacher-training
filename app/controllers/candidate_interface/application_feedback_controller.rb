module CandidateInterface
  class ApplicationFeedbackController < CandidateInterfaceController
    def new
      redirect_to candidate_interface_application_form_path if params[:original_controller].nil?
      @application_feedback_form = CandidateInterface::ApplicationFeedbackForm.new(
        path: params[:path],
        page_title: params[:page_title],
        original_controller: params[:original_controller],
      )
    end

    def create
      @application_feedback_form = CandidateInterface::ApplicationFeedbackForm.new(feedback_params)

      if @application_feedback_form.save(current_application)
        redirect_to candidate_interface_application_feedback_thank_you_path
      else
        track_validation_error(@application_feedback_form)

        render :new
      end
    end

    def thank_you; end

  private

    def feedback_params
      strip_whitespace params.require(:candidate_interface_application_feedback_form).permit(
        :path, :page_title,
        :feedback, :consent_to_be_contacted,
        :original_controller
      )
    end
  end
end
