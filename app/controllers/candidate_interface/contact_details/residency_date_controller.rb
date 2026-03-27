module CandidateInterface
  class ContactDetails::ResidencyDateController < CandidateInterfaceController
    def new
      @country_of_residence = country_of_residence
      @residency_date_form = CandidateInterface::ResidencyDateForm.new(application_form: current_application)
    end

    def edit
      @country_of_residence = country_of_residence
      @residency_date_form = CandidateInterface::ResidencyDateForm.build_from_application(current_application)
      @back_path = back_path
    end

    def create
      @country_of_residence = country_of_residence
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
      @country_of_residence = country_of_residence
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

    def country_of_residence
      COUNTRIES_AND_TERRITORIES[current_application.country] || 'your current country of residence'
    end

    def back_path
      param = params[:origin] || params[:'return-to']

      case param
      when 'application-review'
        candidate_interface_contact_information_review_path
      when 'address'
        candidate_interface_edit_address_path
      else
        candidate_interface_edit_residency_path
      end
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
