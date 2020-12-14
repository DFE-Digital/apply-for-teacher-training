module SupportInterface
  module ApplicationForms
    class ReferencesController < SupportInterfaceController
      def edit_reference_details
        @reference = EditReferenceDetailsForm.new(
          ApplicationForm.find(params[:application_form_id]),
          ApplicationReference.find(params[:reference_id]),
        )
      end

      def update_reference_details
        @reference = EditReferenceDetailsForm.new(
          ApplicationForm.find(params[:application_form_id]),
          ApplicationReference.find(params[:reference_id]),
        )

        @reference.assign_attributes(edit_reference_details_params)
        if @reference.valid?
          @reference.save!
          flash[:success] = 'Reference updated'
          redirect_to support_interface_application_form_path(@reference.application_form)
        else
          render :edit_reference_details
        end
      end

      def edit_reference_feedback
        @reference = EditReferenceFeedbackForm.new(
          ApplicationForm.find(params[:application_form_id]),
          ApplicationReference.find(params[:reference_id]),
        )
      end

      def update_reference_feedback
        @reference = EditReferenceFeedbackForm.new(
          ApplicationForm.find(params[:application_form_id]),
          ApplicationReference.find(params[:reference_id]),
        )

        @reference.assign_attributes(edit_reference_feedback_params)
        if @reference.valid?
          @reference.save!
          flash[:success] = 'Reference updated'
          redirect_to support_interface_application_form_path(@reference.application_form)
        else
          render :edit_reference_feedback
        end
      end

    private

      def edit_reference_details_params
        params.require(:support_interface_application_forms_edit_reference_details_form).permit(:name, :email_address, :relationship, :audit_comment)
      end

      def edit_reference_feedback_params
        params.require(:support_interface_application_forms_edit_reference_feedback_form).permit(:feedback, :audit_comment)
      end
    end
  end
end
