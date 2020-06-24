module CandidateInterface
  class ContactDetails::AddressTypeController < ContactDetails::BaseController
    def edit
      render_404 and return unless FeatureFlag.active?(:international_addresses)

      @contact_details_form = ContactDetailsForm.build_from_application(
        current_application,
      )
    end

    def update
      render_404 and return unless FeatureFlag.active?(:international_addresses)

      @contact_details_form = ContactDetailsForm.new(address_type_params)

      if @contact_details_form.save_address_type(current_application)
        current_application.update!(contact_details_completed: false)

        redirect_to candidate_interface_contact_details_edit_address_path
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

  private

    def address_type_params
      params.require(:candidate_interface_contact_details_form).permit(
        :address_type,
        :country,
      )
    end
  end
end
