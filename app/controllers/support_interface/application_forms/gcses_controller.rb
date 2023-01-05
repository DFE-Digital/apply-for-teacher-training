module SupportInterface
  module ApplicationForms
    class GcsesController < SupportInterfaceController
      def edit_award_year
        @gcse_award_year_form = EditGcseAwardYearForm.new(
          ApplicationQualification.find(params[:gcse_id]),
        )
      end

      def update_award_year
        @gcse_award_year_form = EditGcseAwardYearForm.new(
          ApplicationQualification.find(params[:gcse_id]),
        )

        @gcse_award_year_form.assign_attributes(edit_award_year_params)
        if @gcse_award_year_form.valid?
          @gcse_award_year_form.save!
          flash[:success] = 'GCSE award year updated'
          redirect_to support_interface_application_form_path(@gcse_award_year_form.application_form)
        else
          render :edit_award_year
        end
      end

    private

      def edit_award_year_params
        params.require(
          :support_interface_application_forms_edit_gcse_award_year_form,
        ).permit(:award_year, :audit_comment)
      end
    end
  end
end
