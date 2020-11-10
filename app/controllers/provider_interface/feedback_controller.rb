module ProviderInterface
  class FeedbackController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :requires_make_decisions_permission

    def new
      # feedback_params used in case you arrive here via the Change link
      @application_feedback = RejectedByDefaultFeedbackForm.new(feedback_params)
    end

    def check
      @application_feedback = RejectedByDefaultFeedbackForm.new(feedback_params)
      @application_feedback.valid? || render(action: :new)
    end

    def create
      service = SaveAndSendRejectByDefaultFeedback.new(
        application_choice: @application_choice,
        rejection_reason: feedback_params[:rejection_reason],
      )

      service.call || raise('Unable to SaveAndSendRejectByDefaultFeedback')

      redirect_to provider_interface_application_choice_path(
        application_choice_id: @application_choice.id,
      )
    end

  private

    def feedback_params
      return {} unless params.key?(:provider_interface_rejected_by_default_feedback_form)

      params.require(:provider_interface_rejected_by_default_feedback_form)
        .permit(:rejection_reason)
    end
  end
end
