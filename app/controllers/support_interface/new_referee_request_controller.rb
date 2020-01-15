module SupportInterface
  class NewRefereeRequestController < SupportInterfaceController
    before_action :set_reference, :set_reason

    def show; end

    def deliver
      application_form = @reference.application_form

      SendNewRefereeRequestEmail.call(application_form: application_form, reference: @reference, reason: @reason)

      flash[:success] = t('new_referee_request.success')

      redirect_to support_interface_application_form_path(application_form)
    end

  private

    def set_reference
      @reference = ApplicationReference.find(params[:reference_id])
    end

    def set_reason
      @reason = params[:reason].underscore
    end
  end
end
