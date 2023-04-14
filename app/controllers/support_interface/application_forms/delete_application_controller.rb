module SupportInterface
  module ApplicationForms
    class DeleteApplicationController < SupportInterfaceController
      before_action :find_application_form

      def delete
      end

      def confirm_delete
      end

    private

      def find_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end
    end
  end
end
