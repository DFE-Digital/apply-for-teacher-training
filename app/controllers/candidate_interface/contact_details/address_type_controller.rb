module CandidateInterface
  class ContactDetails::AddressTypeController < CandidateInterfaceController
    def new
      @contact_details_form = load_contact_form
    end

    def edit
      @contact_details_form = load_contact_form
      @return_to = return_to_after_edit(default: candidate_interface_contact_information_review_path)
    end

    def create
      @contact_details_form = ContactDetailsForm.build_from_application(current_application)
      @contact_details_form.assign_attributes(address_type_params)

      if @contact_details_form.save_address_type(current_application)
        redirect_to candidate_interface_new_address_path
      else
        track_validation_error(@contact_details_form)
        render :new
      end
    end

    def update
      @contact_details_form = ContactDetailsForm.build_from_application(
        current_application,
      )
      @contact_details_form.assign_attributes(address_type_params)
      @return_to = return_to_after_edit(default: candidate_interface_personal_details_complete_path)

      if @contact_details_form.save_address_type(current_application)
        redirect_to candidate_interface_edit_address_path
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

  private

    def load_contact_form
      ContactDetailsForm.build_from_application(current_application)
    end

    def address_type_params
      strip_whitespace params.expect(
        candidate_interface_contact_details_form: %i[address_type
                                                     country],
      )
    end
  end
end
