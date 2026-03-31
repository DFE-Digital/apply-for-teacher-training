module CandidateInterface
  class ContactDetails::ResidencyController < CandidateInterfaceController
    def new
      @country_of_residence = current_application.country_of_residence
      @residency_form = CandidateInterface::ResidencyForm.build_from_application(current_application)
    end

    def edit
      @country_of_residence = current_application.country_of_residence
      @residency_form = CandidateInterface::ResidencyForm.build_from_application(current_application)
      @back_path = back_path
    end

    def create
      @country_of_residence = current_application.country_of_residence
      @residency_form = CandidateInterface::ResidencyForm.new(residency_params.merge(application_form: current_application))

      if @residency_form.valid?
        @residency_form.save
        path = @residency_form.since_birth? ? candidate_interface_contact_information_review_path : candidate_interface_new_residency_date_path(origin: 'new-residency')
        redirect_to path
      else
        track_validation_error(@residency_form)
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      @country_of_residence = current_application.country_of_residence
      @residency_form = CandidateInterface::ResidencyForm.new(residency_params.merge(application_form: current_application))

      if @residency_form.valid?
        @residency_form.save
        path = @residency_form.since_birth? ? candidate_interface_contact_information_review_path : candidate_interface_new_residency_date_path
        redirect_to path
      else
        track_validation_error(@residency_form)
        render(:edit, status: :unprocessable_entity)
      end
    end

  private

    def back_path
      case params[:'return-to']
      when 'application-review'
        candidate_interface_contact_information_review_path
      else
        candidate_interface_edit_address_path
      end
    end

    def residency_params
      params
        .fetch(:candidate_interface_residency_form, {})
        .permit(:since_birth)
    end
  end
end
