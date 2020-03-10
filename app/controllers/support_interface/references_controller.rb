module SupportInterface
  class ReferencesController < SupportInterfaceController
    def cancel
      @reference = ApplicationReference.find(params[:reference_id])
    end

    def confirm_cancel
      reference = ApplicationReference.find(params[:reference_id])
      reference.update!(feedback_status: 'cancelled')
      flash[:success] = 'Reference was cancelled'
      redirect_to support_interface_application_form_path(reference.application_form)
    end
  end
end
