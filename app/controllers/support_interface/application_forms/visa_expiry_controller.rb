module SupportInterface
  module ApplicationForms
    class VisaExpiryController < SupportInterfaceController
      before_action :set_application_form

      def edit
        @form = VisaExpiryForm.new(@application_form)
      end

      def update
        @form = VisaExpiryForm.new(@application_form)
        @form.assign_attributes(request_params)

        if @form.save
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit
        end
      end

    private

      def set_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end

      def request_params
        params.expect(
          support_interface_application_forms_visa_expiry_form: [
            'visa_expired_at(3i)',
            'visa_expired_at(2i)',
            'visa_expired_at(1i)',
            'audit_comment',
          ],
        ).transform_keys { |key| start_date_field_to_attribute(key, 'visa_expired_at', 'visa_expired') }
      end
    end
  end
end
