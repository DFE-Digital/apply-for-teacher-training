module SupportInterface
  module ApplicationForms
    class RightToWorkOrStudyController < SupportInterfaceController
      before_action :set_application_form

      def edit
        @right_to_work_or_study_form = RightToWorkOrStudyForm.build_from_application(@application_form)
      end

      def update
        @right_to_work_or_study_form = RightToWorkOrStudyForm.new(right_to_work_params)

        if @right_to_work_or_study_form.save(@application_form)
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit
        end
      end

    private

      def set_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end

      def right_to_work_params
        StripWhitespace.from_hash params.require(:support_interface_application_forms_right_to_work_or_study_form).permit(
          :right_to_work_or_study, :right_to_work_or_study_details
        )
      end
    end
  end
end
