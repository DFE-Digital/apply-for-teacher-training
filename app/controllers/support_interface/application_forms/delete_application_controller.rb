module SupportInterface
  module ApplicationForms
    class DeleteApplicationController < SupportInterfaceController
      before_action :find_application_form

      def delete
        @form = DeleteApplicationForm.new(delete_application_params)

        if @form.save(actor: current_support_user, application_form: @application_form)
          redirect_to support_interface_application_form_path(@application_form.id)
        else
          render :confirm_delete
        end
      end

      def confirm_delete
        @form = DeleteApplicationForm.new(application_form: @application_form)
      end

    private

      def delete_application_params
        params
              .expect(support_interface_application_forms_delete_application_form: %i[accept_guidance audit_comment_ticket])
      end

      def find_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end
    end
  end
end
