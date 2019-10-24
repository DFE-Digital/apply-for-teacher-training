module CandidateInterface
  class ContactDetailsController < CandidateInterfaceController
    def edit
      @contact_details_form = ContactDetailsForm.new
    end

    def update
      @contact_details_form = ContactDetailsForm.new(contact_details_params)

      if @contact_details_form.save(current_candidate.current_application)
        render :show
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
