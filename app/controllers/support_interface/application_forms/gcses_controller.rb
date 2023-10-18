module SupportInterface
  module ApplicationForms
    class GcsesController < SupportInterfaceController
      def edit
        @application_qualification = ApplicationQualification.find(params[:id])

        gcse_form_klass = GcseFormResolver.new(@application_qualification).call

        @gcse_form = gcse_form_klass.build_from_qualification(@application_qualification)
      end

      def update
        @application_qualification = ApplicationQualification.find(params[:id])
        gcse_form_klass = GcseFormResolver.new(@application_qualification).call
        @gcse_form = gcse_form_klass.build_from_qualification(@application_qualification)
        @gcse_form.assign_values(params.require(:support_interface_gcse_form).permit!)

        if @gcse_form.save
          flash[:success] = 'GCSE updated'
          redirect_to support_interface_application_form_path(@gcse_form.application_form)
        else
          render :edit
        end
      end

    private

      def edit_award_year_params
        params.require(
          :support_interface_application_forms_edit_gcse_award_year_form,
        ).permit(:award_year, :audit_comment)
      end

      def edit_grade_params
        params.require(
          :support_interface_application_forms_edit_gcse_grade_form,
        ).permit(:grade, :constituent_grades, :index, :audit_comment)
      end
    end
  end
end
