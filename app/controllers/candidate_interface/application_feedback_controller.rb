module CandidateInterface
  class ApplicationFeedbackController < CandidateInterfaceController
    before_action :set_hidden_field_values, only: %i[new create]

    def new
      @application_feedback_form = CandidateInterface::ApplicationFeedbackForm.new
    end

    def create
      @application_feedback_form = CandidateInterface::ApplicationFeedbackForm.new(feedback_params)

      if @application_feedback_form.save(current_application)
        redirect_to candidate_interface_application_feedback_thank_you_path
      else
        @application_feedback_form.set_booleans
        track_validation_error(@references_relationship_form)

        render :new
      end
    end

    def thank_you; end

  private

    def set_hidden_field_values
      @path = params[:path] || params.dig('candidate_interface_application_feedback_form', 'path')
      @page_title = params[:page_title] || params.dig('candidate_interface_application_feedback_form', 'page_title')
    end

    def feedback_params
      params.require(:candidate_interface_application_feedback_form).permit(
        :path, :page_title, :does_not_understand_section,
        :need_more_information, :answer_does_not_fit_format,
        :other_feedback, :consent_to_be_contacted
      )
    end
  end
end
