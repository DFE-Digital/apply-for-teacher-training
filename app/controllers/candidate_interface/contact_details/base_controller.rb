module CandidateInterface
  class ContactDetails::BaseController < CandidateInterfaceController
    def edit
      @contact_details_form = ContactDetailsForm.new
    end

    def update
      @contact_details_form = ContactDetailsForm.new(contact_details_params)

      if @contact_details_form.save_base(current_candidate.current_application)
        redirect_to candidate_interface_contact_details_edit_address_path
      else
        render :edit
      end
    end

  private

    def contact_details_params
      params.require(:candidate_interface_contact_details_form).permit(:phone_number)
    end
  end
end
