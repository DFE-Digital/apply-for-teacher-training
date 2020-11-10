module ProviderInterface
  class FeedbackController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :requires_make_decisions_permission

    def new
      @application_feedback = RejectedByDefaultFeedbackForm.new
    end

    def check
      @application_feedback = RejectedByDefaultFeedbackForm.new(feedback_params)
      @application_feedback.valid?
      render action: :new
    end

  private

    def feedback_params
      return {} unless params.key?(:provider_interface_rejected_by_default_feedback_form)

      params.require(:provider_interface_rejected_by_default_feedback_form)
        .permit(:rejection_reason)
    end
  end
end
