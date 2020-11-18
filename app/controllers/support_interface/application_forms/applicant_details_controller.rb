module SupportInterface
  module ApplicationForms
    class ApplicantDetailsController < SupportInterfaceController
      def edit
        @details = EditApplicantDetailsForm.new(
          ApplicationForm.find(params[:application_form_id]),
        )
      end

      def update
        @details = EditApplicantDetailsForm.new(
          ApplicationForm.find(params[:application_form_id]),
        )

        @details.assign_attributes(edit_application_params)

        if @details.valid?
          @details.save!
          flash[:success] = 'Applicant details updated'
          redirect_to support_interface_application_form_path(@details.application_form)
        else
          render :edit
        end
      end

    private

      def edit_application_params
        params.require(
          :support_interface_application_forms_edit_applicant_details_form,
        ).permit(:phone_number)
      end
    end
  end
end
