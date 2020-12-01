module CandidateInterface
  class FindFeedbackController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!

    def new
      @find_feedback_form = CandidateInterface::FindFeedbackForm.new(
        path: params[:path],
        original_controller: params[:original_controller],
      )
    end

    def create
      @find_feedback_form = CandidateInterface::FindFeedbackForm.new(feedback_params)

      if @find_feedback_form.save || @find_feedback_form.user_is_a_bot?
        redirect_to candidate_interface_find_feedback_thank_you_path
      else
        track_validation_error(@find_feedback_form)

        render :new
      end
    end

    def thank_you; end

  private

    def feedback_params
      params.require(:candidate_interface_find_feedback_form).permit(
        :path, :original_controller, :hidden_feedback_field, :feedback, :email_address
      )
    end
  end
end
