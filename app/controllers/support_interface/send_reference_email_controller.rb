module SupportInterface
  class SendReferenceEmailController < SupportInterfaceController
    before_action :set_reference

    def new
      @send_reference_email = SupportInterface::SendReferenceEmailForm.new
    end

    def create
      @send_reference_email = SupportInterface::SendReferenceEmailForm.new(send_reference_email_params)

      if @send_reference_email.valid?
        if @send_reference_email.chase?
          redirect_to support_interface_chase_reference_path(@reference)
        else
          reason = @send_reference_email.new_referee_email.dasherize

          redirect_to support_interface_new_referee_request_path(@reference, reason)
        end
      else
        render :new
      end
    end

  private

    def set_reference
      @reference = ApplicationReference.find(params[:reference_id])
    end

    def send_reference_email_params
      params.fetch(:support_interface_send_reference_email_form, {}).permit(
        :choice, :new_referee_email
      )
    end
  end
end
