module CandidateInterface
  class ContactDetails::AddressTypeController < ContactDetails::BaseController
    def edit
      @contact_details_form = ContactDetailsForm.build_from_application(
        current_application,
      )
    end

    def update
      @contact_details_form = ContactDetailsForm.new(address_type_params)

      if @contact_details_form.save_international_address(current_application)
        current_application.update!(contact_details_completed: false)

        redirect_to candidate_interface_contact_details_review_path
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

  private

    def international_address_params
      params.require(:candidate_interface_contact_details_form).permit(
        :international_address,
      )
    end
  end
end
