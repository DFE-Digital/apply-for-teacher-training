module CandidateInterface
  class ContactDetails::AddressController < ContactDetails::BaseController
    def edit
      @contact_details_form = ContactDetailsForm.build_from_application(
        current_application,
      )
    end

    def update
      @contact_details_form = ContactDetailsForm.new(
        contact_details_params.merge(address_type: current_application.address_type),
      )

      if @contact_details_form.save_address(current_application)
        current_application.update!(contact_details_completed: false)

        redirect_to candidate_interface_contact_details_review_path
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

  private

    def contact_details_params
      params.require(:candidate_interface_contact_details_form).permit(
        :address_line1, :address_line2, :address_line3, :address_line4, :postcode, :international_address
      )
        .transform_values(&:strip)
    end
  end
end
