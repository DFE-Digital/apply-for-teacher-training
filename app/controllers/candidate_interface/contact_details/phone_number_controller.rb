module CandidateInterface
  class ContactDetails::PhoneNumberController < CandidateInterfaceController
    def new
      @contact_details_form = load_contact_form
    end

    def edit
      @contact_details_form = load_contact_form
      @return_to = return_to_after_edit(default: candidate_interface_contact_information_review_path)
    end

    def create
      @contact_details_form = ContactDetailsForm.build_from_application(current_application)
      @contact_details_form.assign_attributes(contact_details_params)

      if @contact_details_form.save_base(current_application)
        redirect_to candidate_interface_new_address_type_path
      else
        track_validation_error(@contact_details_form)
        render :new
      end
    end

    def update
      @contact_details_form = ContactDetailsForm.build_from_application(current_application)
      @contact_details_form.assign_attributes(contact_details_params)

      @return_to = return_to_after_edit(default: candidate_interface_contact_information_review_path)

      if @contact_details_form.save_base(current_application)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

  private

    def load_contact_form
      ContactDetailsForm.build_from_application(current_application)
    end

    def contact_details_params
      strip_whitespace params.expect(candidate_interface_contact_details_form: [:phone_number])
    end
  end
end
