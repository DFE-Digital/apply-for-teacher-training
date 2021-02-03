module SupportInterface
  module ApplicationForms
    class GcsesController < SupportInterfaceController
      def edit
        @gcse_form = EditGcseForm.new(
          ApplicationQualification.find(params[:gcse_id]),
        )
      end

      def update
        @gcse_form = EditGcseForm.new(
          ApplicationQualification.find(params[:gcse_id]),
        )

        @gcse_form.assign_attributes(edit_application_params)
        if @gcse_form.valid?
          @gcse_form.save!
          flash[:success] = 'GCSE updated'
          redirect_to support_interface_application_form_path(@gcse_form.application_form)
        else
          render :edit
        end
      end

    private

      def edit_application_params
        params.require(
          :support_interface_application_forms_edit_gcse_form,
        ).permit(:award_year, :audit_comment)
      end
    end
  end
end
