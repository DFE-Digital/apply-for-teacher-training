module CandidateInterface
  class ContactDetails::ResidencyDateController < CandidateInterfaceController
    def new
      @country_of_residence = country_of_residence
      @residency_date_form = CandidateInterface::ResidencyDateForm.build_from_application(current_application)
    end

    def edit
      @country_of_residence = country_of_residence
      @residency_date_form = CandidateInterface::ResidencyDateForm.build_from_application(current_application)
      @return_to = return_to_after_edit(default: candidate_interface_contact_information_review_path)
    end

    def create
      @residency_date_form = CandidateInterface::ResidencyDateForm.new(residency_date_params)

      if @residency_date_form.valid?
        @residency_date_form.save(current_application)
        redirect_to candidate_interface_contact_information_review_path
      else
        track_validation_error(@residency_date_form)
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      @residency_date_form = CandidateInterface::ResidencyDateForm.new(residency_date_params)

      if @residency_date_form.valid?
        @residency_date_form.save(current_application)
        redirect_to candidate_interface_contact_information_review_path
      else
        track_validation_error(@residency_date_form)
        render(:edit, status: :unprocessable_entity)
      end
    end

  private

    def country_of_residence
      COUNTRIES_AND_TERRITORIES[current_application.country]
    end

    def residency_date_params
      params.expect(
        candidate_interface_residency_date_form: %i[
          residency_date_from(1i)
          residency_date_from(2i)
          residency_date_from(3i)
        ],
      ).transform_keys { |key| start_date_field_to_attribute(key, 'residency_date_from') }
    end
  end
end
