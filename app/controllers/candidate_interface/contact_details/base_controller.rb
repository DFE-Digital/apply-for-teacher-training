module CandidateInterface
  class ContactDetails::BaseController < CandidateInterfaceController
    def edit
      @contact_details_form = ContactDetailsForm.build_from_application(
        current_candidate.current_application,
      )
    end

    def update
      @contact_details_form = ContactDetailsForm.new(contact_details_params)
      application_form = current_candidate.current_application

      if @contact_details_form.save_base(application_form)
        updated_contact_details_form = ContactDetailsForm.build_from_application(
          application_form,
        )

        if updated_contact_details_form.valid?(:address)
          redirect_to candidate_interface_contact_details_review_path
        else
          redirect_to candidate_interface_contact_details_edit_address_path
        end
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
