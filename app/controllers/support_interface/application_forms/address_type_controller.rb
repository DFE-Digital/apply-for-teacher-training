module SupportInterface
  module ApplicationForms
    class AddressTypeController < SupportInterfaceController
      before_action :set_application_form

      def edit
        @details_form = EditAddressDetailsForm.build_from_application_form(@application_form)
      end

      def update
        @details_form = EditAddressDetailsForm.new(address_type_params)
        if @details_form.save_address_type(@application_form)
          redirect_to support_interface_application_form_edit_address_details_path
        else
          render :edit
        end
      end

    private

      def address_type_params
        params.expect(
          support_interface_application_forms_edit_address_details_form: %i[address_type
                                                                            country],
        )
      end

      def set_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end
    end
  end
end
