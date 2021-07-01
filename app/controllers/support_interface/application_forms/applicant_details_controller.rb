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
        ).permit(:first_name, :last_name, :email_address, :'date_of_birth(3i)', :'date_of_birth(2i)',
                 :'date_of_birth(1i)', :phone_number, :audit_comment)
          .transform_keys { |key| dob_field_to_attribute(key) }
          .transform_values(&:strip)
      end

      def dob_field_to_attribute(key)
        case key
        when 'date_of_birth(3i)' then 'day'
        when 'date_of_birth(2i)' then 'month'
        when 'date_of_birth(1i)' then 'year'
        else key
        end
      end
    end
  end
end
