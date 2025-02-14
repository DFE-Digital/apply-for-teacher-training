module SupportInterface
  module ApplicationForms
    class AddressDetailsController < SupportInterfaceController
      before_action :set_application_form

      def edit
        @details_form = EditAddressDetailsForm.build_from_application_form(@application_form)
      end

      def update
        @details_form = EditAddressDetailsForm.new(
          address_details_params.merge(address_type: @application_form.address_type),
        )

        if @details_form.save_address(@application_form)
          flash[:success] = 'Address details updated'
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit
        end
      end

    private

      def address_details_params
        StripWhitespace.from_hash params
          .require(:support_interface_application_forms_edit_address_details_form)
          .permit(
            :address_line1, :address_line2, :address_line3, :address_line4, :postcode, :audit_comment
          )
      end

      def set_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end
    end
  end
end
