module SupportInterface
  module ApplicationForms
    class AddressDetailsController < SupportInterfaceController
      def edit
        @details = details_form
      end

      def update
        application_form.assign_attributes(address_details_params)
        @details = details_form
        if @details.save_address(application_form)
          flash[:success] = 'Address details updated'
          redirect_to support_interface_application_form_path(application_form)
        else
          render :edit
        end
      end

    private

      def address_details_params
        params.require(:support_interface_application_forms_edit_address_details_form).permit(
          :address_line1, :address_line2, :address_line3, :address_line4, :postcode, :international_address, :audit_comment
        )
          .transform_values(&:strip)
      end

      def details_form
        @details ||= EditAddressDetailsForm.build_from_application_form(application_form)
      end

      def application_form
        @application_form ||= ApplicationForm.find(params[:application_form_id])
      end
    end
  end
end
