module SupportInterface
  module ApplicationForms
    class DeleteApplicationController < SupportInterfaceController
      before_action :find_application_form

      def delete
        @form = DeleteApplicationForm.new(application_form: @application_form)

        if @form.save
          redirect_to support_interface_application_form_path
        else
          render :confirm_delete
        end
      end

      def confirm_delete
        @form = DeleteApplicationForm.new(application_form: @application_form)
      end

    private

      def find_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end
    end
  end
end
