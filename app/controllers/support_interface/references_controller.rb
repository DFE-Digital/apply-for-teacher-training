module SupportInterface
  class ReferencesController < SupportInterfaceController
    before_action :build_reference
    before_action :redirect_to_application_form_path_unless_feedback_requested_and_test_environment,
                  only: %i[impersonate_and_give impersonate_and_decline]

    def cancel; end

    def confirm_cancel
      CancelReferee.new.call(reference: @reference)
      flash[:success] = 'Reference was cancelled'
      redirect_to support_interface_application_form_path(@reference.application_form)
    end

    def reinstate
      render_404 and return unless ReferenceActionsPolicy.new(@reference).reinstatable?
    end

    def confirm_reinstate
      render_404 and return unless ReferenceActionsPolicy.new(@reference).reinstatable?

      ReinstateReference.call(@reference)
      flash[:success] = 'Reference was reinstated'
      redirect_to support_interface_application_form_path(@reference.application_form)
    end

    def impersonate_and_give
      redirect_to referee_interface_reference_relationship_path(token: @reference.refresh_feedback_token!)
    end

    def impersonate_and_decline
      redirect_to referee_interface_refuse_feedback_path(token: @reference.refresh_feedback_token!)
    end

  private

    def build_reference
      @reference = ApplicationReference.find(params[:reference_id])
    end

    def redirect_to_application_form_path_unless_feedback_requested_and_test_environment
      unless @reference.feedback_requested? && HostingEnvironment.test_environment?
        redirect_to support_interface_application_form_path(reference.application_form) and
          return
      end
    end
  end
end
