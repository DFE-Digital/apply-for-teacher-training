module CandidateInterface
  class ContactDetails::ResidencyDateController < CandidateInterfaceController
    def new
      @country_of_residence = current_application.country_of_residence
      @residency_date_form = CandidateInterface::ResidencyDateForm.new(application_form: current_application)
      @back_path = back_path
    end

    def edit
      @country_of_residence = current_application.country_of_residence
      @residency_date_form = CandidateInterface::ResidencyDateForm.build_from_application(current_application)
      @back_path = back_path
    end

    def create
      @country_of_residence = current_application.country_of_residence
      @residency_date_form = CandidateInterface::ResidencyDateForm.new(application_form: current_application, **residency_date_params)

      if @residency_date_form.valid?
        @residency_date_form.save
        redirect_to candidate_interface_contact_information_review_path
      else
        track_validation_error(@residency_date_form)
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      @country_of_residence = current_application.country_of_residence
      @residency_date_form = CandidateInterface::ResidencyDateForm.new(application_form: current_application, **residency_date_params)

      if @residency_date_form.valid?
        @residency_date_form.save
        redirect_to candidate_interface_contact_information_review_path
      else
        track_validation_error(@residency_date_form)
        render(:edit, status: :unprocessable_entity)
      end
    end

  private

    def back_path
      param = params[:origin] || params[:'return-to']

      case param
      when 'application-review'
        candidate_interface_contact_information_review_path
      when 'new-address'
        candidate_interface_address_path
      when 'edit-address'
        candidate_interface_edit_address_path
      when 'new-residency'
        candidate_interface_new_residency_path
      when 'change-residency'
        candidate_interface_edit_residency_path(return_to_params)
      else
        candidate_interface_edit_residency_path
      end
    end

    def return_to_params
      { 'return-to' => 'application-review' }
    end

    def residency_date_params
      params.expect(
        candidate_interface_residency_date_form: %i[
          date(1i)
          date(2i)
          date(3i)
        ],
      ).transform_keys { |key| start_date_field_to_attribute(key, 'date') }
    end
  end
end
