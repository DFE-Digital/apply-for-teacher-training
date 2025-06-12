module SupportInterface
  class ReferencesController < SupportInterfaceController
    before_action :build_reference
    before_action :redirect_to_application_form_path_unless_feedback_requested_and_test_environment,
                  only: %i[impersonate_and_give impersonate_and_decline]

    def reinstate; end

    def confirm_reinstate
      UndoReferenceRefusal.new(@reference).call
      flash[:success] = 'Reference was reinstated'
      redirect_to support_interface_application_form_path(@reference.application_form)
    end

    def impersonate_and_give
      redirect_to referee_interface_confidentiality_path(token: @reference.refresh_feedback_token!)
    end

    def impersonate_and_decline
      redirect_to referee_interface_refuse_feedback_path(token: @reference.refresh_feedback_token!)
    end

    def destroy
      @form = SupportInterface::ApplicationForms::DeleteReferenceForm.new(actor: current_support_user,
                                                                          reference: @reference)
    end

    def confirm_destroy
      @form = SupportInterface::ApplicationForms::DeleteReferenceForm.new(delete_reference_params
                                                                            .merge(actor: current_support_user,
                                                                                   reference: @reference))
      if @form.save
        flash[:success] = 'Reference deleted'
        redirect_to support_interface_application_form_path(@reference.application_form)
      else
        render :destroy
      end
    end

  private

    def build_reference
      @reference = ApplicationReference.find(params[:reference_id])
    end

    def redirect_to_application_form_path_unless_feedback_requested_and_test_environment
      unless @reference.feedback_requested? && HostingEnvironment.test_environment?
        redirect_to support_interface_application_form_path(reference.application_form) and return
      end
    end

    def delete_reference_params
      params
            .expect(support_interface_application_forms_delete_reference_form: %i[accept_guidance audit_comment_ticket])
    end
  end
end
