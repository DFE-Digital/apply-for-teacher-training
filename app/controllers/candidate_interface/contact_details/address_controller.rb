module CandidateInterface
  class ContactDetails::AddressController < CandidateInterfaceController
    def edit
      @contact_details_form = ContactDetailsForm.new
    end

    def update
      @contact_details_form = ContactDetailsForm.new(contact_details_params)

      if @contact_details_form.save_address(current_candidate.current_application)
        redirect_to candidate_interface_contact_details_review_path
      else
        render :edit
      end
    end

  private

    def contact_details_params
      params.require(:candidate_interface_contact_details_form).permit(
        :address_line1, :address_line2, :address_line3, :address_line4, :postcode
      )
    end
  end
end
