module SupportInterface
  module ApplicationForms
    class ReferencesController < SupportInterfaceController
      def edit
        @reference = EditReferenceForm.new(
          ApplicationForm.find(params[:application_form_id]),
          ApplicationReference.find(params[:reference_id]),
        )
      end

      def update
        @reference = EditReferenceForm.new(
          ApplicationForm.find(params[:application_form_id]),
          ApplicationReference.find(params[:reference_id]),
        )

        @reference.assign_attributes(edit_reference_params)
        if @reference.valid?
          @reference.save!
          flash[:success] = 'Reference updated'
          redirect_to support_interface_application_form_path(@reference.application_form)
        else
          render :edit
        end
      end

    private

      def edit_reference_params
        params.require(:support_interface_application_forms_edit_reference_form).permit(:name, :email_address, :relationship, :feedback, :audit_comment)
      end
    end
  end
end
