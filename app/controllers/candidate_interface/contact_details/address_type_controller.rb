module CandidateInterface
  class ContactDetails::AddressTypeController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def new
      @contact_details_form = ContactDetailsForm.new
    end

    def create
      @contact_details_form = ContactDetailsForm.new(address_type_params)

      if @contact_details_form.save_address_type(current_application)
        redirect_to candidate_interface_new_address_path
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

    def edit
      @contact_details_form = ContactDetailsForm.build_from_application(
        current_application,
      )
      @return_to = return_to_after_edit(default: candidate_interface_personal_details_complete_path)
    end

    def update
      @contact_details_form = ContactDetailsForm.new(address_type_params)
      @return_to = return_to_after_edit(default: candidate_interface_personal_details_complete_path)

      if @contact_details_form.save_address_type(current_application)
        return redirect_to candidate_interface_edit_address_path(redirect_back_to_application_review_page_params) if redirect_back_to_application_review_page?

        redirect_to candidate_interface_edit_address_path
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

  private

    def address_type_params
      strip_whitespace params.require(:candidate_interface_contact_details_form).permit(
        :address_type,
        :country,
      )
    end
  end
end
