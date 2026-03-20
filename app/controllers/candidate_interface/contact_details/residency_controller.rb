module CandidateInterface
  class ContactDetails::ResidencyController < CandidateInterfaceController
    def new
      @country_of_residence = country_of_residence
      @residency_form = CandidateInterface::ResidencyForm.build_from_application(current_application)
    end

    def edit
      @country_of_residence = country_of_residence
      @residency_form = CandidateInterface::ResidencyForm.build_from_application(current_application)
      @return_to = return_to_after_edit(default: candidate_interface_contact_information_review_path)
    end

    def create
      @residency_form = CandidateInterface::ResidencyForm.new(residency_params)

      if @residency_form.valid?
        @residency_form.save(current_application)
        path = @residency_form.since_birth? ? candidate_interface_contact_information_review_path : candidate_interface_new_residency_date_path
        redirect_to path
      else
        track_validation_error(@residency_form)
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      @residency_form = CandidateInterface::ResidencyForm.new(residency_params)

      if @residency_form.valid?
        @residency_form.save(current_application)
        path = @residency_form.since_birth? ? candidate_interface_contact_information_review_path : candidate_interface_edit_residency_date_path
        redirect_to path
      else
        track_validation_error(@residency_form)
        render(:edit, status: :unprocessable_entity)
      end
    end

  private

    def country_of_residence
      COUNTRIES_AND_TERRITORIES[current_application.country]
    end

    def residency_params
      params
      .fetch(:candidate_interface_residency_form, {})
      .permit(:since_birth)
    end
  end
end
