module CandidateInterface
  class ContactDetails::AddressController < CandidateInterfaceController
    def new
      @contact_details_form = load_contact_form
    end

    def edit
      @contact_details_form = load_contact_form
    end

    def create
      @contact_details_form = ContactDetailsForm.build_from_application(
        current_application,
      )
      @contact_details_form.assign_attributes(contact_details_params)

      if @contact_details_form.save_address(current_application)
        path = address_same_as_nationality? ? candidate_interface_new_residency_path : candidate_interface_new_residency_date_path
        redirect_to path
      else
        track_validation_error(@contact_details_form)
        render :new
      end
    end

    def update
      @contact_details_form = ContactDetailsForm.build_from_application(current_application)
      @contact_details_form.assign_attributes(contact_details_params)

      if @contact_details_form.save_address(current_application)
        path = address_same_as_nationality? ? candidate_interface_edit_residency_path : candidate_interface_edit_residency_date_path
        redirect_to path
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

  private

    def address_same_as_nationality?
      country_of_residence = current_application.country

      record = CODES_AND_NATIONALITIES[country_of_residence]

      return false if nationalities.empty?
      return false unless record

      record.in?(nationalities)
    end
    # TODO: include person with British nationality living in list of UK islands/BOTs in British journey

    def nationalities
      [
        current_application&.first_nationality,
        current_application&.second_nationality,
        current_application&.third_nationality,
        current_application&.fourth_nationality,
        current_application&.fifth_nationality,
      ].compact_blank
    end

    def load_contact_form
      ContactDetailsForm.build_from_application(current_application)
    end

    def contact_details_params
      strip_whitespace params.expect(
        candidate_interface_contact_details_form: %i[address_line1 address_line2 address_line3 address_line4 postcode],
      )
    end
  end
end
