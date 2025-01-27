module SupportInterface
  module ApplicationForms
    class EmailSubscriptionController < SupportInterfaceController
     
      before_action :set_application_form
    
      def edit
        @email_subscription_form = EmailSubscriptionForm.build_from_application(@application_form)
      end

      def update
        @email_subscription_form = EmailSubscriptionForm.new(unsubscribed_from_emails_params)

        if @email_subscription_form.save(@application_form)
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit
        end
      end

      private

      def unsubscribed_from_emails_params
        params.require(:support_interface_email_subscription_form).permit(:unsubscribed_from_emails)
      end

      def set_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end
    end
  end
end
