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
        if address_same_as_nationality?
          redirect_to candidate_interface_new_residency_path
        else
          current_application.update(country_residency_since_birth: false)
          redirect_to candidate_interface_new_residency_date_path(origin: 'address')
        end
      else
        track_validation_error(@contact_details_form)
        render :new
      end
    end

    def update
      @contact_details_form = ContactDetailsForm.build_from_application(current_application)
      @contact_details_form.assign_attributes(contact_details_params)

      if @contact_details_form.save_address(current_application)
        if address_same_as_nationality?
          redirect_to candidate_interface_edit_residency_path
        else
          current_application.update(country_residency_since_birth: false)
          redirect_to candidate_interface_edit_residency_date_path(origin: 'address')
        end
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

  private

    def address_same_as_nationality?
      country_of_residence = current_application&.country

      # true if candidate is British and lives in an overseas territory
      return true if 'British'.in?(nationalities) && british_overseas_territory_or_island?(country_of_residence)

      record = CODES_AND_NATIONALITIES[country_of_residence]

      return false if nationalities.empty?
      return false unless record

      record.in?(nationalities)
    end

    def british_overseas_territory_or_island?(country)
      bots_and_islands = %w[GB GB-WLS GB-CYM GB-SCT GB-NIR IM GG JE AI BM BAT IO VG KY FK GI MS PN GS SH TC]

      country.in?(bots_and_islands)
    end

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
